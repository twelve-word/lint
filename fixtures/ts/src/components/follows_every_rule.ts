import { getItems } from "../api/items";

export async function followsEveryRule(value: unknown): Promise<boolean> {
  if (value === 2) return true;
  if (value == null) return false;
  // @ts-expect-error: a string where a number is declared, kept to test the rule's description option
  const count: number = "3";
  const items = await getItems();
  return items.length > count;
}
