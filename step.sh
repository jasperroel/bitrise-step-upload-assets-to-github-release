#!/bin/bash

# Environment variables we depend on
declare debug
declare personal_access_token
declare github_release_tag
declare files_to_attach_list
declare create_release
declare ignore_errors

if [ "${debug}" == "true" ]; then
  set -ex
fi

# avoid globbing (expansion of *).
set -f

# Step logic
echo "Adding ${files_to_attach_list} to Github release ${github_release_tag}"

files_to_attach_array=(${files_to_attach_list//|/ })
if [ "${debug}" == "yes" ]; then
  echo "Unwrapped files_to_attach_list to these files:" "${files_to_attach_array[@]}"
fi

assets=()
for f in "${files_to_attach_array[@]}"; do
  [ -f "${BITRISE_SOURCE_DIR}/$f" ] && assets+=(--attach "${BITRISE_SOURCE_DIR}/$f");
done

if [ "${#assets[@]}" -eq 0 ]; then
  echo "WARNING: 0 assets to attach found"
  if [ "$ignore_errors" == "no" ]; then
    exit 1
  fi
  exit 0
fi

if [ "${debug}" == "yes" ]; then
  echo "Found these files:" "${assets[@]}"
fi

if [ "${debug}" == "yes" ]; then
  export HUB_VERBOSE="true"
fi
export GITHUB_TOKEN="${personal_access_token}"

# Does this release already exist?
RELEASE_NOTES=$(hub release show "${github_release_tag}")
RELEASE_NOTES_EXIST=$?

if [ "$RELEASE_NOTES_EXIST" -ne 0 ] && [ "$create_release" == "yes" ]; then
  hub release create -m "" -t "${github_release_tag}" "${github_release_tag}"
fi

RELEASE_EDIT=$(hub release edit -m "" "${assets[@]}" "${github_release_tag}")
RELEASE_EDIT_EXIT_CODE=$?

# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
if [ "$ignore_errors" == "no" ]; then
  exit ${RELEASE_EDIT_EXIT_CODE}
fi

exit 0

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
