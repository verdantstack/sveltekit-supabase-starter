[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: McpTool

A tool as MCP describes it: a name, a description, and a JSON Schema.

## Properties

### description

> **description**: `string`

***

### handler()

> **handler**: (`supabase`, `args`) => `Promise`\<`unknown`\>

#### Parameters

##### supabase

`SupabaseClient`

##### args

`Record`\<`string`, `unknown`\>

#### Returns

`Promise`\<`unknown`\>

***

### inputSchema

> **inputSchema**: `Record`\<`string`, `unknown`\>

***

### name

> **name**: `string`
