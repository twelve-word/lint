# The Twelveword shared lint rules. `make check` is what the PR check runs.
.PHONY: help install check
.DEFAULT_GOAL := help

help:
	@echo "Twelveword shared lint rules."
	@echo ""
	@echo "  make install   Install the packages of the TypeScript fixture (pnpm)"
	@echo "  make check     Prove each rule still catches its fixture, and the clean fixtures pass"

install:
	pnpm -C fixtures/ts install

check:
	./check_rules.sh
