# Preserve frontend IR/architecture and compiler command files for validation.
BAMBU_EXTRA_FLAGS += --no-clean
# Shared arrays need concurrent tasks; the C++ testbench supplies its own oracle.
BAMBU_EXTRA_FLAGS += -DBAMBU_SKIP_VERIFICATION
