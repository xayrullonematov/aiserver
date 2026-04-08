from typing import Optional
from fastapi import Query

def foo(a: str = Query(...), b: int = 1):
    pass

def bar(a: str = Query(...), b: int):
    pass

if __name__ == "__main__":
    print("Success")
