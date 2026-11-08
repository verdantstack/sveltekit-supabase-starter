[**sveltekit-supabase-starter**](../../README.md)

***

# Interface: AiProvider

Abstraction over an AI provider.

## Properties

### name

> `readonly` **name**: `string`

Provider name.

## Methods

### chat()

> **chat**(`messages`, `options?`): `Promise`\<`string`\>

Send a chat request and return the full response.

#### Parameters

##### messages

[`AiMessage`](AiMessage.md)[]

Conversation messages.

##### options?

[`AiChatOptions`](AiChatOptions.md)

Request options.

#### Returns

`Promise`\<`string`\>

Generated text.

***

### chatStream()

> **chatStream**(`messages`, `options?`): `AsyncIterable`\<`string`\>

Stream a chat response token-by-token.

#### Parameters

##### messages

[`AiMessage`](AiMessage.md)[]

Conversation messages.

##### options?

[`AiChatOptions`](AiChatOptions.md)

Request options.

#### Returns

`AsyncIterable`\<`string`\>

Async iterable of text chunks.
