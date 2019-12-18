#!/bin/bash
set -ex
# avoid globbing (expansion of *).
set -f

# Environment variables we depend on
declare github_pat
declare github_release_tag
declare files_to_attach_list

# Step logic
echo "Adding ${files_to_attach_list} to Github release ${github_release_tag}"

files_to_attach_array=(${files_to_attach_list//|/ })
echo "Unwrapped files_to_attach_list to these files:" "${files_to_attach_array[@]}"

assets=()
for f in "${files_to_attach_array[@]}"; do
  [ -f "${BITRISE_SOURCE_DIR}/$f" ] && assets+=(--attach "${BITRISE_SOURCE_DIR}/$f");
done

echo "Found these files:" "${assets[@]}"

export HUB_VERBOSE="true"
export GITHUB_TOKEN="${github_pat}"
hub release edit -m "" "${assets[@]}" "${github_release_tag}"

# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
# envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'

# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
