EMPTY_STATUS=https://api.github.com/repos/platformsh-templates/directus/statuses/f8730dc2bb4dbc9f2c276903aa6e06f4761272b9
PR_STATUS=https://api.github.com/repos/platformsh-templates/directus/statuses/db484e1c5590d2d622310efaff3a82e8a7d83689
STATUS=$PR_STATUS

LENGTH=$(curl -s $STATUS | jq -r 'length')

# if [ $LENGTH > 0 ]; then
#     echo $LENGTH
# else
#     echo "Not on a Platform.sh integrated environment. Skipping."
# fi

if [ $LENGTH == 0 ]; then
    # echo $LENGTH
    echo "Not on a Platform.sh integrated environment. Skipping."
else
    echo $LENGTH
    # echo "Not on a Platform.sh integrated environment. Skipping."
fi
