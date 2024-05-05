.PHONY: release-patch
release-patch:
	@bump2version patch  # Bump the version to the next patch level
	@if git rev-parse v$(shell bump2version --dry-run --list patch | grep new_version | sed -E 's/.*=//') >/dev/null 2>&1; then \
		echo "Tag v$(shell bump2version --dry-run --list patch | grep new_version | sed -E 's/.*=//') already exists. Skipping tag creation."; \
	else \
		git tag -a v$(shell bump2version --dry-run --list patch | grep new_version | sed -E 's/.*=//') -m "Release v$(shell bump2version --dry-run --list patch | grep new_version | sed -E 's/.*=//')"; \
		git push --tags; \
	fi
	@git push  # Push the changes to the remote repository
