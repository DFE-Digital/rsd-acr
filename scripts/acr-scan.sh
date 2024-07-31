#! /bin/bash

################################################################################
# Author:
#   Ash Davies <@DrizzlyOwl>
# Version:
#   0.2.0
# Description:
#   Search Azure Container Registry for unused dev tags and remove the images
# Usage:
#   ./acr-scan.sh -s "my-subscription" -r "my-container-registry" [-d 1] [-u 1]
################################################################################

DRY_RUN=0
UNTAG=0

while getopts "r:s:q:d:u:" opt; do
  case $opt in
    r)
      REGISTRY=$OPTARG
      ;;
    s)
      AZ_SUBSCRIPTION_SCOPE=$OPTARG
      ;;
    d)
      DRY_RUN=1
      ;;
    u)
      UNTAG=1
      ;;
    *)
      ;;
  esac
done

# If a subscription scope has not been defined on the command line using '-e'
# then prompt the user to select a subscription from the account
if [ -z "${AZ_SUBSCRIPTION_SCOPE}" ]; then
  AZ_SUBSCRIPTIONS=$(
    az account list --output json |
    jq -c '[.[] | select(.state == "Enabled").name]'
  )

  echo "🌐 Choose an option"
  AZ_SUBSCRIPTIONS="$(echo "$AZ_SUBSCRIPTIONS" | jq -r '. | join(",")')"

  # Read from the list of available subscriptions and prompt them to the user
  # with a numeric index for each one
  if [ -n "$AZ_SUBSCRIPTIONS" ]; then
    IFS=',' read -r -a array <<< "$AZ_SUBSCRIPTIONS"

    echo
    cat -n < <(printf "%s\n" "${array[@]}")
    echo

    n=""

    # Ask the user to select one of the indexes
    while true; do
        read -rp 'Select subscription to query: ' n
        # If $n is an integer between one and $count...
        if [ "$n" -eq "$n" ] && [ "$n" -gt 0 ]; then
          break
        fi
    done

    i=$((n-1)) # Arrays are zero-indexed
    AZ_SUBSCRIPTION_SCOPE="${array[$i]}"
  fi
fi

if [ -z "$REGISTRY" ]; then
  echo "[!] Please specify the name of an ACR"
  exit
fi

# $REGISTRY is the ACR name
CONTAINER_APP_LIST=$(az containerapp list --subscription "$AZ_SUBSCRIPTION_SCOPE" --output json)
CONTAINER_APP_IMAGE_MANIFEST=$(echo "$CONTAINER_APP_LIST" | jq -r --arg acr "$REGISTRY" '.[] | .properties.template.containers[].image | select(. | startswith($acr)) | split("/")[1]')
jq -c -n --arg names "$CONTAINER_APP_IMAGE_MANIFEST" '$names | split("\n")' > containerapps.existing.json

echo "Container App images currently in use from this ACR:"
echo "$CONTAINER_APP_IMAGE_MANIFEST"

if [ "$DRY_RUN" == "1" ]; then
  echo "[!] Dry run enabled. Commands will be printed instead of executed"
fi

REPOSITORIES=$(az acr repository list --name "$REGISTRY" --output tsv)
for REPO in $REPOSITORIES; do

  # Remove all tags from unused images
  if [ "$UNTAG" == "1" ]; then
    echo "[!] Untagging all unused images from $REPO"
    TAG_MANIFEST=$(az acr repository show-tags -n "$REGISTRY" --repository "$REPO")
    IMAGE_TAGS=$(echo "$TAG_MANIFEST" | jq -r --arg image "$REPO:" '.[] | select(. | contains("latest") | not) | ($image+.)')

    for TAG in $IMAGE_TAGS; do
      MUST_SKIP=$(jq --arg tag "$TAG" < "containerapps.existing.json" '[.[] | select(. == $tag)] | length')

      if [ "$MUST_SKIP" == "1" ]; then
        echo "# $TAG is in use and will be skipped"
      else
        if [ "$DRY_RUN" == "1" ]; then
          echo "az acr repository untag --name $REGISTRY --image $TAG"
        else
          az acr repository untag --name "$REGISTRY" --image "$TAG"
        fi
      fi

    done
  # Prune all 'untagged' images
  else
    echo "[!] Removing all untagged images from $REPO"
    ALL_UNTAGGED=$(az acr manifest list-metadata -r "$REGISTRY" -n "$REPO" --query "[?tags[0]==null].digest" -o tsv)

    for TAG in $ALL_UNTAGGED; do
      if [ "$DRY_RUN" == "1" ]; then
        echo "az acr repository delete -n $REGISTRY -t $REPO@$TAG --yes"
      else
        az acr repository delete -n "$REGISTRY" -t "$REPO@$TAG" --yes
      fi
    done
  fi
done

rm "containerapps.existing.json"
