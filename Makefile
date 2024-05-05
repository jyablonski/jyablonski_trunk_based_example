.PHONY: bump-patch
bump-patch:
	@bump2version patch
	@git push --tags
	@git push