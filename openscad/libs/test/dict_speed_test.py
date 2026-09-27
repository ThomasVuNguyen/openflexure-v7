#! /usr/bin/env python
'''
Simple test of the dictionary speed for different length dictionaries.
'''
import time
import subprocess
import random
import os
from tempfile import mkstemp

def main():
    """
    Createing a scad file and timing its execution.
    python over some powers of 10 and create a scad dictionary with 10, 100,
    1000 keys. Then writes in 20 scad key lookup commands. This is output to a file.
    """
    this_dir = os.path.dirname(__file__)
    temp_scad_file = os.path.join(this_dir, "temp.scad")
    temp_descriptor, temp_path = mkstemp(suffix='.echo')

    for i in range(3):
        scad = """
        use <../libdict.scad>

        // This is a tests and should be moved into a test folder
        dict = ["""
        d_length = 10**(i+1)
        for j in range(d_length):
            scad += f'["{j}", {random.random()}]'
            if j == d_length-1:
                scad += "];\n\n"
            else:
                scad += ",\n"
        scad += """
        val = key_lookup("0", dict);
        val1 = key_lookup("1", dict);
        val2 = key_lookup("2", dict);
        val3 = key_lookup("3", dict);
        val4 = key_lookup("4", dict);
        val5 = key_lookup("5", dict);
        val6 = key_lookup("6", dict);
        val7 = key_lookup("7", dict);
        val8 = key_lookup("8", dict);
        val9 = key_lookup("9", dict);
        val10 = key_lookup("0", dict);
        val11 = key_lookup("1", dict);
        val12 = key_lookup("2", dict);
        val13 = key_lookup("3", dict);
        val14 = key_lookup("4", dict);
        val15 = key_lookup("5", dict);
        val16 = key_lookup("6", dict);
        val17 = key_lookup("7", dict);
        val18 = key_lookup("8", dict);
        val19 = key_lookup("9", dict);
        echo(val);
        """

        with open(temp_scad_file, 'w') as file_obj:
            file_obj.write(scad)


        start_time = time.time()
        subprocess.run(["openscad", "-o", temp_path, temp_scad_file], check=True)
        delta_t = time.time()-start_time

        with open(temp_path, 'r') as file_obj:
            out = file_obj.read()
        if out.startswith("ECHO"):
            print(f"Program ran without error for dictionary length {d_length}")
            print(f"For length {d_length}:  20 lookups takes: {delta_t:.4f}s")
            print(f"That is {delta_t/20:.4f}s per lookup")
        else:
            print(f"Openscad error for dictionary length {d_length}!")
    os.close(temp_descriptor)
    os.remove(temp_scad_file)


if __name__ == "__main__":
    main()
