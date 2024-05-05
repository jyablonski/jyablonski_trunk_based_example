.PHONY: bump-patch
bump-patch:
	@bump2version patch
	@git push --tags -m "Release v$(shell cat VERSION)"
	@git push