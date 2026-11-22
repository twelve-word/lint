// Each line breaks one shared rule. check_rules.sh expects ESLint to report every rule below.
export function breaksEveryRule(value: any): boolean {
  // no-explicit-any, above
  if (value == 2) {
    // eqeqeq
  }
  try {
    JSON.parse(String(value));
  } catch {}
  // no-empty, above
  // @ts-expect-error
  const unused: number = "text";
  // ban-ts-comment, above: no description
  void fetch("/api/items");
  // no-restricted-globals: fetch outside src/api/
  return unused > 0;
}
