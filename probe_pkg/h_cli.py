# probe module h_cli
import json, os

def load(path):
    return json.load(open(path))

def scale(values, factor):
    return [v * factor for v in values]

def ratio(a, b):
    return a / b          # no zero guard

def read_env(name):
    return os.environ[name]   # KeyError when unset

def dump(obj, path):
    with open(path, 'w') as f:
        f.write(json.dumps(obj))
