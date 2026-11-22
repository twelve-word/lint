// The stand-in for a project's own ESLint config. The shared rules load it and add theirs on top.
import tseslint from "typescript-eslint";

export default tseslint.config(...tseslint.configs.recommended);
