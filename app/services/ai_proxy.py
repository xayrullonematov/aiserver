import logging
from typing import AsyncGenerator, List, Dict, Any, Optional
import openai
from openai import AsyncOpenAI
import anthropic
from anthropic import AsyncAnthropic

logger = logging.getLogger(__name__)

class AIProxy:
    _instance: Optional['AIProxy'] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(AIProxy, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        self.providers = ["openai", "anthropic", "gemini", "grok", "custom"]
        self.default_system_prompt = (
            "You are an AI Server Copilot assistant. You help users manage their remote servers, "
            "write code, and debug applications directly on their infrastructure. "
            "You have access to the project structure and logs. Be concise, accurate, and safe."
        )

    async def get_providers(self) -> List[str]:
        """Return list of supported AI providers."""
        return self.providers

    async def chat(
        self, 
        provider: str, 
        api_key: str, 
        messages: List[Dict[str, str]], 
        model: Optional[str] = None,
        base_url: Optional[str] = None,
        stream: bool = True,
        context: Optional[str] = None
    ) -> AsyncGenerator[str, None]:
        """
        Route chat request to the correct provider.
        api_key is never stored, used only for this request.
        """
        
        # Prepare messages with system prompt and context
        full_messages = []
        system_content = self.default_system_prompt
        if context:
            system_content += f"\n\nPROJECT CONTEXT:\n{context}"
        
        # Anthropic handles system prompt differently than OpenAI
        if provider == "anthropic":
            async for chunk in self._chat_anthropic(api_key, messages, system_content, model, stream):
                yield chunk
        else:
            # OpenAI compatible providers
            full_messages.append({"role": "system", "content": system_content})
            full_messages.extend(messages)
            
            async for chunk in self._chat_openai_compatible(
                provider, api_key, full_messages, model, base_url, stream
            ):
                yield chunk

    async def _chat_openai_compatible(
        self, provider: str, api_key: str, messages: List[Dict[str, str]], 
        model: Optional[str], base_url: Optional[str], stream: bool
    ) -> AsyncGenerator[str, None]:
        
        if provider == "openai":
            client = AsyncOpenAI(api_key=api_key)
            default_model = model or "gpt-4o"
        elif provider == "grok":
            client = AsyncOpenAI(api_key=api_key, base_url="https://api.x.ai/v1")
            default_model = model or "grok-beta"
        elif provider == "gemini":
            client = AsyncOpenAI(
                api_key=api_key, 
                base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
            )
            default_model = model or "gemini-1.5-pro"
        elif provider == "custom":
            if not base_url:
                raise ValueError("base_url is required for custom provider")
            client = AsyncOpenAI(api_key=api_key, base_url=base_url)
            default_model = model or "gpt-4o" # or whatever the custom endpoint expects
        else:
            raise ValueError(f"Unsupported provider: {provider}")

        try:
            response = await client.chat.completions.create(
                model=default_model,
                messages=messages,
                stream=stream
            )

            if stream:
                async for chunk in response:
                    content = chunk.choices[0].delta.content
                    if content:
                        yield content
            else:
                yield response.choices[0].message.content
        except Exception as e:
            logger.error(f"OpenAI compatible error for {provider}: {e}")
            yield f"Error from {provider}: {str(e)}"
        finally:
            await client.close()

    async def _chat_anthropic(
        self, api_key: str, messages: List[Dict[str, str]], 
        system_prompt: str, model: Optional[str], stream: bool
    ) -> AsyncGenerator[str, None]:
        
        client = AsyncAnthropic(api_key=api_key)
        default_model = model or "claude-3-5-sonnet-20241022"

        try:
            if stream:
                async with client.messages.stream(
                    model=default_model,
                    max_tokens=4096,
                    system=system_prompt,
                    messages=messages
                ) as stream_obj:
                    async for text in stream_obj.text_stream:
                        yield text
            else:
                response = await client.messages.create(
                    model=default_model,
                    max_tokens=4096,
                    system=system_prompt,
                    messages=messages
                )
                yield response.content[0].text
        except Exception as e:
            logger.error(f"Anthropic error: {e}")
            yield f"Error from Anthropic: {str(e)}"
        finally:
            await client.close()

# Global singleton instance
ai_proxy = AIProxy()
