# Engineering rules for 86

Read START-HERE.md first, then 125A-Engineering/START-HERE.md and the relevant QA completeness contract. Avoid writing copyrighted VM binaries or licensed apps into Git or artifacts.

Do not use network-exposed insecure Windows-95 services. Never call a green script syntax test a working Windows-95 guest. Preserve private user files, do not force overwrite or rewrite VM images. Prefer self-checking scripts and fail-closed behavior.

Tests should include negative cases: missing BIOS, missing guest image, wrong image size, overwriting VM, and missing/bad SHA256. Report untested features separately. Cakewalk needs a lawfully sourced installation package and a real in-guest test.
