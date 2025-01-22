from openai import OpenAI
import os
from dotenv import load_dotenv, find_dotenv


def get_openai_answer(ques, model_name="gpt-4o-mini", require_json=False, temperature=0.0):
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
            }
        )
    else:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=False,
            temperature=temperature
        )

    return response.choices[0].message.content

def get_ollama_answers(ques, model_name, require_json=False, temperature=0.0):
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
            }
        )
    else:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=True,
            max_tokens=8192,
            temperature=temperature
        )
    full_response = ""
    for chunk in response:
        if chunk.choices[0].delta.content:
            full_response += chunk.choices[0].delta.content
    return full_response

def get_gptgod_answers(ques, model_name, require_json=False, temperature=0.0):
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
            }
        )
    else:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            temperature=temperature
        )

    return response.choices[0].message.content

def get_deepseek_answers(ques, model_name, require_json=False, temperature=0.0):
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
            }
        )
    else:
        response = client.chat.completions.create(
            model=model_name,
            messages=messages,
            stream=False,
            temperature=temperature
        )

    return response.choices[0].message.content

    # full_response = ""
    # for chunk in response:
    #     if chunk.choices[0].delta.content:
    #         full_response += chunk.choices[0].delta.content
    # return full_response

def get_llm_answers(ques, model_name,require_json=False, temperature=0.0):
    if 'gpt' in model_name:
        return get_openai_answer(ques, model_name, require_json, temperature)
    elif model_name == "llama2" or "deepseek-r1:70b" in model_name:
        return get_ollama_answers(ques, model_name, require_json, temperature)
    elif "deepseek-chat" in model_name:
        return get_deepseek_answers(ques, model_name, require_json, temperature )
    else:
        return get_gptgod_answers(ques, model_name, require_json, temperature)