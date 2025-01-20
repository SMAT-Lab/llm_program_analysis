import time
from openai import OpenAI
import os
from dotenv import load_dotenv, find_dotenv


def get_openai_answer(ques, model_name="gpt-4o-mini", require_json=False, temperature=0.0, timeout=100):
    _ = load_dotenv(find_dotenv())  # read local .env file
    api_key = os.environ['OPENAI_API_KEY']
    api_base = os.environ['OPENAI_API_BASE']

    client = OpenAI(api_key=api_key, base_url=api_base)

    messages = ques if isinstance(ques, list) else [{"role": "user", "content": ques}]
    
    if require_json:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=False,
            temperature=temperature,
            response_format={
                'type': 'json_object'
            },
            timeout=timeout
        )
    else:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=False,
            temperature=temperature,
            timeout=timeout
        )

    return response.choices[0].message.content

def get_ollama_answers(ques, model_name, require_json=False, temperature=0.0, timeout=100):
    _ = load_dotenv(find_dotenv())
    api_key = os.environ['OLLAMA_API_KEY']
    api_base = os.environ["OLLAMA_API_BASE"]

    client = OpenAI(api_key=api_key, base_url=api_base)

    messages = ques if isinstance(ques, list) else [{"role": "user", "content": ques}]
    
    if require_json:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=True,
            max_tokens=8192,
            temperature=temperature,
            response_format={
                'type': 'json_object'
            },
            timeout=timeout
        )
    else:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=True,
            max_tokens=8192,
            temperature=temperature,
            timeout=timeout
        )
    full_response = ""
    for chunk in response:
        if chunk.choices[0].delta.content:
            full_response += chunk.choices[0].delta.content
    return full_response

def get_gptgod_answers(ques, model_name, require_json=False, temperature=0.0, timeout=100):
    _ = load_dotenv(find_dotenv())
    api_key = os.environ['GPTGOD_API_KEY']
    api_base = os.environ["GPTGOD_API_BASE"]

    client = OpenAI(api_key=api_key, base_url=api_base)

    messages = ques if isinstance(ques, list) else [{"role": "user", "content": ques}]
    
    if require_json:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            temperature=temperature,
            response_format={
                'type': 'json_object'
            },
            timeout=timeout
        )
    else:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            temperature=temperature,
            timeout=timeout
        )

    return response.choices[0].message.content

def get_deepseek_answers(ques, model_name, require_json=False, temperature=0.0, timeout=100):
    _ = load_dotenv(find_dotenv())
    api_key = os.environ['DEEPSEEK_API_KEY']
    api_base = os.environ["DEEPSEEK_API_BASE"]

    client = OpenAI(api_key=api_key, base_url=api_base)

    messages = ques if isinstance(ques, list) else [{"role": "user", "content": ques}]
    if require_json:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            temperature=temperature,
            response_format={
                'type': 'json_object'
            },
            timeout=timeout
        )
    else:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=False,
            temperature=temperature,
            timeout=timeout
        )

    return response.choices[0].message.content

    # full_response = ""
    # for chunk in response:
    #     if chunk.choices[0].delta.content:
    #         full_response += chunk.choices[0].delta.content
    # return full_response
def get_llm_answers(ques, model_name, require_json=False, temperature=0.0, max_retries=3, timeout=100):
    for attempt in range(max_retries):
        try:
            if 'gpt' in model_name:
                return get_openai_answer(ques, model_name, require_json, temperature, timeout)
            elif model_name == "llama2":
                return get_ollama_answers(ques, model_name, require_json, temperature, timeout)
            elif "deepseek" in model_name:
                return get_deepseek_answers(ques, model_name, require_json, temperature, timeout)
            else:
                return get_gptgod_answers(ques, model_name, require_json, temperature, timeout)
        except Exception as e:
            if attempt == max_retries - 1:
                raise Exception(f"请求失败,已重试{max_retries}次: {str(e)}")
            print(f"请求失败,正在进行第{attempt + 1}次重试...")
            time.sleep(1)  # 重试前等待1秒