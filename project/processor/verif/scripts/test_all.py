import os
import subprocess
from pathlib import Path


def get_d_files(programs):
    return list(filter(lambda s: '.d' in s and 'dnum' not in s, programs))


def find_address(file_path, prefix):
    f = open(file_path, "r")
    contents = f.read()
    lines = contents.split("\n")
    filtered_lines = list(filter(lambda s: prefix in s, lines))
    if len(filtered_lines) == 0: return None
    filtered_lines = [list(filter(lambda s: prefix in s, line.split(","))) for line in filtered_lines]
    return filtered_lines[0][0].replace(prefix, "").strip()


def find_fail_address(file_path):
    return find_address(file_path, "<fail>")


def find_pass_address(file_path):
    return find_address(file_path, "<pass>")


def check_if_test_failed(fail_condition, pass_condition, file_path):
    f = open(file_path, "r")
    contents = f.read()
    found_pass = False
    found_failed = False
    for item in contents.split("\n"):
        if pass_condition in item and item.startswith('[E]'):
            found_pass = True
        if fail_condition in item and item.startswith('[E]'):
            found_failed = True
    return (not found_pass) or (found_failed)


def build_map(base_path, programs):
    fail_map = {}
    for d in programs:
        key = str(d).replace(".d", "")
        file_path = (base_path / d).resolve()
        fail_address = find_fail_address(file_path)
        pass_address = find_pass_address(file_path)
        if fail_address is not None and pass_address is not None:
            fail_map[key] = {"fail": fail_address}
            fail_map[key]["pass"] = pass_address
    return fail_map


def Merge(dict1, dict2):
    res = {**dict1, **dict2}
    return res


def run_verilator_tests(addresses, data_path):
    base_script = "make run VERILATOR=1 TEST=test_pd MEM_PATH=" + str(data_path)
    for key in addresses:
        script = base_script + "/" + str(key) + ".x"
        script = script.split(" ")
        subprocess.run(script)


def format_address(address, length):
    for _ in range(length, 8):
        address = "0" + address
    return address


def verify_trace_files(addresses, output_path):
    num_tests = len(addresses)
    num_fails = 0
    for key in addresses:
        fail_address = format_address(addresses[key]["fail"], len(addresses[key]["fail"]))
        pass_address = format_address(addresses[key]["pass"], len(addresses[key]["pass"]))

        fail_condition = fail_address + " 1"
        pass_condition = pass_address + " 1"

        file_name = key + ".trace"
        file_path = (output_path / file_name).resolve()

        if(check_if_test_failed(fail_condition, pass_condition, file_path)):
            num_fails += 1
            print(key + ": Failed")
        else:
            print(key + ": Passed")
    print(str(num_tests - num_fails) + " / " + str(num_tests) + " Tests Passed!")


base_path = Path(__file__).parent
relative_path_insn = '../rv32-benchmarks/individual-instructions'
relative_path_simp = '../rv32-benchmarks/simple-programs'
relative_path_data = '../data'
relative_path_output = '../sim/verilator/test_pd'

individual_path = (base_path / relative_path_insn).resolve()
simple_path = (base_path / relative_path_simp).resolve()
data_path = (base_path / relative_path_data).resolve()
output_path = (base_path / relative_path_output).resolve()

simple_programs = os.listdir(simple_path)
individual_instructions = os.listdir(individual_path)

simple_d_files = get_d_files(simple_programs)
instruction_d_files = get_d_files(individual_instructions)

simple_map = build_map(simple_path, simple_d_files)
instruction_map = build_map(individual_path, instruction_d_files)
addresses = Merge(simple_map, instruction_map)

#run_verilator_tests(addresses, data_path)
verify_trace_files(addresses, output_path)

