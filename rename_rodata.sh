#!/bin/bash

for file in $(find . -name "*.o"); do
    new_rodata=".text.$(echo -n "$file.rodata" | md5sum | awk '{print $1}')"
    objcopy --set-section-flags .rodata=contents,alloc,load,readonly,code --rename-section .rodata=$new_rodata $file
done