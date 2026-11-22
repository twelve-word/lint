// The shared ESLint rules for every Twelveword project. Twelveword decided this on 2026-11-22.
// Only rules that catch real bugs, and the one architecture rule. Style and size limits stay with
// each project's own config.
// The hook loads the project's own config from ESLINT_PROJECT_CONFIG and adds these rules on top.
const { default: projectConfig } = await import(process.env.ESLINT_PROJECT_CONFIG);

export default [
  ...[projectConfig].flat(),
  {
    rules: {
      "no-empty": "error",
      eqeqeq: ["error", "smart"],
    },
  },
  {
    files: ["**/*.ts", "**/*.tsx"],
    rules: {
      "@typescript-eslint/no-explicit-any": "error",
      "@typescript-eslint/ban-ts-comment": ["error", { "ts-expect-error": "allow-with-description" }],
    },
  },
  {
    // Every backend call goes through src/api/. Route handlers and middleware proxy the backend.
    files: ["**/src/**"],
    ignores: [
      "**/src/api/**",
      "**/route.{js,jsx,mjs,cjs,ts,tsx}",
      "**/middleware.{js,jsx,mjs,cjs,ts,tsx}",
      "**/proxy.{js,jsx,mjs,cjs,ts,tsx}",
    ],
    rules: {
      "no-restricted-globals": [
        "error",
        { name: "fetch", message: "Call the backend through a module in src/api/." },
      ],
    },
  },
];
