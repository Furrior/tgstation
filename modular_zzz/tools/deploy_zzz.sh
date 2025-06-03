#!/bin/bash

# This script will deploy our modular icon assets so iconforge can use them in spritesheet generation
# This includes modular_zzz/icons and greyscale json configs

mkdir -p \
    $1/modular_zzz/icons \
    $1/modular_zzz/code/datums/greyscale/json_configs

cp -r modular_zzz/icons/* $1/modular_zzz/icons/
cp -r modular_zzz/code/datums/greyscale/json_configs/* $1/modular_zzz/code/datums/greyscale/json_configs/
