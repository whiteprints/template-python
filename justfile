# SPDX-FileCopyrightText: © 2024 The "Whiteprints" contributors <whiteprints@pm.me>
#
# SPDX-License-Identifier: MIT-0


# Uncomment this to use project local uv cache.
# export UV_CACHE_DIR := ".just/.cache/uv"
export UV_NO_PROGRESS := "true"


# list all receipts
default:
    @just --list

# Clean Python temporary files
clean-python:
    @just uvx "pyclean ."

# Clean the generated Bill of Material (BOM)
clean-BOM:
    rm -rf BOM

# Clean the documentation
clean-docs:
    rm -rf docs_build

# Clean the just working directory
clean-just:
    rm -rf .just

# Clean everything
clean-all:
    @just clean-python
    @just clean-BOM
    @just clean-just
    @just clean-docs

# Run a receipt for all Python versions (found in the .python-versions file). Works for all receipt whose first argument is a Python version
for-all-python receipt args="":
    for python in `grep -v '^#' {{ justfile_directory() }}/.python-versions`; do \
        just {{ receipt }} $python {{ args }}; \
    done

# initialise Just working directory and synchronize the virtualenv
init:
    [ -d .just ] || mkdir -p .just

venv receipt python license="": init
    [ -d ".just/{{ receipt }}/{{ license }}/{{ python }}" ] || \
        mkdir -p ".just/{{ receipt }}/{{ license }}/{{ python }}"
    rm -rf ".just/{{ receipt }}/{{ license }}/{{ python }}/tmp"
    mkdir -p ".just/{{ receipt }}/{{ license }}/{{ python }}/tmp"
    uv venv \
        --no-project \
        --no-config \
        --python={{ python }} \
        ".just/{{ receipt }}/{{ license }}/{{ python }}/.venv"

# Run `uv`
uv args="":
    uv \
    {{ args }}

# Run `uv tool run`
uvx args="":
    @just uv " \
        tool run \
        --isolated \
        {{ args }} \
    "

# Test the template
test python license: (venv "test" python license)
    @just uvx "\
        --with whiteprints-template-context \
        copier copy \
        --trust \
        --force \
        --vcs-ref HEAD \
        '{{ justfile_directory() }}' \
        '{{ justfile_directory() }}/.just/test/{{ license }}/{{ python }}/tmp' \
        --data project_name='My Awesome Project' \
        --data author='Romain Brault' \
        --data organisation='RomainBrault' \
        --data author_email='mail@romainbrault.com' \
        --data organisation_email='mail@romainbrault.com' \
        --data code_license_id='{{ license }}' \
        --data resources_license_id='{{ license }}'  \
        --data copyright_holder='Romain Brault' \
        --data copyright_holder_email='mail@romainbrault.com' \
        --data line_length='79' \
        --data target_python_version='`echo \"py{{ python }}\" | tr -d .`'\
    "
    @just uvx "\
        --directory '\
            {{ justfile_directory() }}/\
            .just/test/{{ license }}/{{ python }}/tmp\
        ' \
        --from rust-just just all\
    "

test-open-source python:
    @just test {{ python }} "MIT OR Apache-2.0"

test-proprietary python:
    @just test {{ python }} ""

all:
    @just for-all-python test-open-source
    @just for-all-python test-proprietary
