# verify github url is correct

	PATH_PARENT=$(basename "$PWD")
	PATH_GRANDPARENT=$(basename "$(dirname "$PWD")")
	echo "git url https://github.com/${PATH_GRANDPARENT}/${PATH_PARENT}.git"

# publish to github

	PATH_PARENT=$(basename "$PWD")
	PATH_GRANDPARENT=$(basename "$(dirname "$PWD")")
	rm -rf .git;
	git init;
	git checkout -b main;
	find . -name ".DS_Store" -depth -exec rm {} \;
	find . -exec touch {} \;
	git add .;
	git commit -m "checkpoint commit";
	git remote add origin "https://github.com/${PATH_GRANDPARENT}/${PATH_PARENT}.git"
	git push -u --force origin main;
	git branch --set-upstream-to=origin/main main;
	git pull;git push;
