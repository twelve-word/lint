// The one place a fetch is allowed: a module in src/api/.
export async function getItems(): Promise<string[]> {
  const response = await fetch("/api/items");
  return (await response.json()) as string[];
}
