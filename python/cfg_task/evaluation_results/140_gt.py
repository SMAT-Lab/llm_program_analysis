import json
from typing import Any, Type, TypeVar, cast, get_args, get_origin
class ConversionError(ValueError):
    pass
pass
def __convert_list(value: Any) -> list:
    if isinstance(value, (list, tuple, set)):
        return list(value)
    elif isinstance(value, dict):
        return list(value.items())
    elif isinstance(value, str):
        value = value.strip()
        if value.startswith('[') and value.endswith(']'):
            try:
                return json.loads(value)
            except json.JSONDecodeError:
                return [value]
        else:
            return [value]
    else:
        return [value]
isinstance(value, (list, tuple, set))
return [value]
return {'value': value}
NUM = TypeVar('NUM', int, float)
def __convert_num(value: Any, num_type: Type[NUM]) -> NUM:
    if isinstance(value, (list, dict, tuple, set)):
        return num_type(len(value))
    elif isinstance(value, num_type):
        return value
    else:
        try:
            return num_type(float(value))
        except (ValueError, TypeError):
            return num_type(0)
isinstance(value, (list, dict, tuple, set))
return num_type(0)
def convert(value: Any, target_type: Type[T]) -> T:
    try:
        return cast(T, _try_convert(value, target_type, raise_on_mismatch=False))
    except Exception as e:
        raise ConversionError(f'Failed to convert {value} to {target_type}') from e
try:
    return cast(T, _try_convert(value, target_type, raise_on_mismatch=False))
except Exception as e:
    raise ConversionError(f'Failed to convert {value} to {target_type}') from e
return cast(T, _try_convert(value, target_type, raise_on_mismatch=False))
raise ConversionError(f'Failed to convert {value} to {target_type}') from e
return list(value)
isinstance(value, dict)
isinstance(value, num_type)
return num_type(len(value))
def __convert_bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    elif isinstance(value, str):
        if value.lower() in ['true', '1']:
            return True
        else:
            return False
    else:
        return bool(value)
isinstance(value, bool)
return list(value.items())
isinstance(value, str)
def __convert_str(value: Any) -> str:
    if isinstance(value, str):
        return value
    else:
        return json.dumps(value)
isinstance(value, str)
return value
try:
    return num_type(float(value))
except (ValueError, TypeError):
    return num_type(0)
return num_type(float(value))
return value
isinstance(value, str)
def _try_convert(value: Any, target_type: Type, raise_on_mismatch: bool) -> Any:
    origin = get_origin(target_type)
    args = get_args(target_type)
    if origin is None:
        origin = target_type
    if origin not in [list, dict, tuple, str, set, int, float, bool]:
        return value
    if isinstance(value, origin):
        if not args:
            return value
        elif origin is list:
            return [convert(v, args[0]) for v in value]
        elif origin is tuple:
            if len(args) == 1:
                return tuple((convert(v, args[0]) for v in value))
            else:
                return tuple((convert(v, t) for (v, t) in zip(value, args)))
        elif origin is dict:
            (key_type, val_type) = args
            return {convert(k, key_type): convert(v, val_type) for (k, v) in value.items()}
        elif origin is set:
            return {convert(v, args[0]) for v in value}
        else:
            return value
    elif raise_on_mismatch:
        raise TypeError(f'Value {value} is not of expected type {target_type}')
    elif origin is list:
        value = __convert_list(value)
        if args:
            return [convert(v, args[0]) for v in value]
        else:
            return value
    elif origin is dict:
        value = __convert_dict(value)
        if args:
            (key_type, val_type) = args
            return {convert(k, key_type): convert(v, val_type) for (k, v) in value.items()}
        else:
            return value
    elif origin is tuple:
        value = __convert_tuple(value)
        if args:
            if len(args) == 1:
                return tuple((convert(v, args[0]) for v in value))
            else:
                return tuple((convert(v, t) for (v, t) in zip(value, args)))
        else:
            return value
    elif origin is str:
        return __convert_str(value)
    elif origin is set:
        value = __convert_set(value)
        if args:
            return {convert(v, args[0]) for v in value}
        else:
            return value
    elif origin is int:
        return __convert_num(value, int)
    elif origin is float:
        return __convert_num(value, float)
    elif origin is bool:
        return __convert_bool(value)
    else:
        return value
origin = get_origin(target_type)
args = get_args(target_type)
origin Is None
return [value]
value = value.strip()
value.startswith('[') and value.endswith(']')
def __convert_dict(value: Any) -> dict:
    if isinstance(value, str):
        try:
            result = json.loads(value)
            if isinstance(result, dict):
                return result
            else:
                return {'value': result}
        except json.JSONDecodeError:
            return {'value': value}
    elif isinstance(value, list):
        return {i: value[i] for i in range(len(value))}
    elif isinstance(value, tuple):
        return {i: value[i] for i in range(len(value))}
    elif isinstance(value, dict):
        return value
    else:
        return {'value': value}
isinstance(value, str)
def __convert_tuple(value: Any) -> tuple:
    if isinstance(value, (str, list, set)):
        return tuple(value)
    elif isinstance(value, dict):
        return tuple(value.items())
    elif isinstance(value, (int, float, bool)):
        return (value,)
    elif isinstance(value, tuple):
        return value
    else:
        return (value,)
isinstance(value, (str, list, set))
def __convert_set(value: Any) -> set:
    if isinstance(value, (str, list, tuple)):
        return set(value)
    elif isinstance(value, dict):
        return set(value.items())
    elif isinstance(value, set):
        return value
    else:
        return {value}
isinstance(value, (str, list, tuple))
return json.dumps(value)
return value
value.lower() In ['true', '1']
return bool(value)
origin = target_type
return [value]
try:
    return json.loads(value)
except json.JSONDecodeError:
    return [value]
return json.loads(value)
try:
    result = json.loads(value)
    if isinstance(result, dict):
        return result
    else:
        return {'value': result}
except json.JSONDecodeError:
    return {'value': value}
result = json.loads(value)
isinstance(result, dict)
isinstance(value, list)
isinstance(value, dict)
return tuple(value)
return set(value)
isinstance(value, dict)
return False
return True
origin NotIn [list, dict, tuple, str, set, int, float, bool]
return {'value': result}
return result
isinstance(value, tuple)
return {i: value[i] for i in range(len(value))}
return tuple(value.items())
isinstance(value, (int, float, bool))
return set(value.items())
isinstance(value, set)
return value
isinstance(value, dict)
return {i: value[i] for i in range(len(value))}
isinstance(value, tuple)
return (value,)
return {value}
return value
not args
raise_on_mismatch
return {'value': value}
return value
return value
return (value,)
origin Is list
return value
raise TypeError(f'Value {value} is not of expected type {target_type}')
origin Is list
return [convert(v, args[0]) for v in value]
origin Is tuple
origin Is dict
value = __convert_list(value)
args
len(args) Eq 1
origin Is dict
value = __convert_dict(value)
args
origin Is tuple
return value
return [convert(v, args[0]) for v in value]
T = TypeVar('T')
def type_match(value: Any, target_type: Type[T]) -> T:
    return cast(T, _try_convert(value, target_type, raise_on_mismatch=True))
return cast(T, _try_convert(value, target_type, raise_on_mismatch=True))
return tuple((convert(v, args[0]) for v in value))
return tuple((convert(v, t) for (v, t) in zip(value, args)))
origin Is set
(key_type, val_type) = args
return {convert(k, key_type): convert(v, val_type) for (k, v) in value.items()}
return value
(key_type, val_type) = args
return {convert(k, key_type): convert(v, val_type) for (k, v) in value.items()}
origin Is str
value = __convert_tuple(value)
args
return value
return {convert(v, args[0]) for v in value}
return __convert_str(value)
origin Is set
return value
len(args) Eq 1
origin Is int
value = __convert_set(value)
args
return tuple((convert(v, t) for (v, t) in zip(value, args)))
return tuple((convert(v, args[0]) for v in value))
origin Is float
return __convert_num(value, int)
return value
return {convert(v, args[0]) for v in value}
origin Is bool
return __convert_num(value, float)
return value
return __convert_bool(value)