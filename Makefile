include .env
export

deploy:
	${MAKE} --directory=./web3webdeploy deploy
.PHONY: deploy

# Update all submodules (and submodules of submodules of submodules etc.) to the latest version
# This will by default get the latest head or whatever branch is specific in .gitmodules
update:
	git submodule update --init --recursive --remote
.PHONY: update

# Merge preferring our commits over the template changes
template-update:
	git remote add template https://github.com/Plopmenz/foundry-template.git
	git fetch template
	git merge template/main -X ours --squash --allow-unrelated-histories || true
	git remote remove template
	${MAKE} clean
.PHONY: template-update

# Merge without preference in merge conflicts
template-update-manual:
	git remote add template https://github.com/Plopmenz/foundry-template.git
	git fetch template
	git merge template/main --squash --allow-unrelated-histories || true
	git remote remove template
	${MAKE} clean
.PHONY: template-update-manual

# Possible we could also add the following, but is there a need?
# Ideally these also take the configuration in consideration
clean:
	rm -rf deploy/counters/Counter.ts
	rm -rf deploy/counters/ProxyCounter.ts
	rmdir deploy/counters
	rm -rf src/Counter.sol
	rm -rf src/ProxyCounter.sol
	rm -rf test/Counter.t.sol

	rm -rf ./web3webdeploy/.next 
	rm -rf cache
	rm -rf out
.PHONY: clean

# Analyzers
analyze:
	${MAKE}  --directory=./analyzers all
.PHONY: analyze

slither:
	${MAKE}  --directory=./analyzers slither
.PHONY: slither

mythril:
	${MAKE}  --directory=./analyzers mythril
.PHONY: mythril