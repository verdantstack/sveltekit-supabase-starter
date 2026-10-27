[**sveltekit-supabase-starter**](../../README.md)

***

# Class: MockAiProvider

Mock AI provider returning canned responses (development/testing).

## Implements

- [`AiProvider`](../interfaces/AiProvider.md)

## Constructors

### Constructor

> **new MockAiProvider**(): `MockAiProvider`

#### Returns

`MockAiProvider`

## Properties

### name

> `readonly` **name**: `"mock"` = `'mock'`

Provider name.

#### Implementation of

[`AiProvider`](../interfaces/AiProvider.md).[`name`](../interfaces/AiProvider.md#name)

## Methods

### chat()

> **chat**(`messages`, `options?`): `Promise`\<`string`\>

Return a canned echo response.

#### Parameters

##### messages

[`AiMessage`](../interfaces/AiMessage.md)[]

Conversation messages.

##### options?

[`AiChatOptions`](../interfaces/AiChatOptions.md)

#### Returns

`Promise`\<`string`\>

Mocked reply.

#### Implementation of

[`AiProvider`](../interfaces/AiProvider.md).[`chat`](../interfaces/AiProvider.md#chat)

***

### chatStream()

> **chatStream**(`messages`, `options?`): `AsyncIterable`\<`string`\>

Stream the canned response word-by-word.

#### Parameters

##### messages

[`AiMessage`](../interfaces/AiMessage.md)[]

Conversation messages.

##### options?

[`AiChatOptions`](../interfaces/AiChatOptions.md)

#### Returns

`AsyncIterable`\<`string`\>

Async iterable of chunks.

#### Implementation of

[`AiProvider`](../interfaces/AiProvider.md).[`chatStream`](../interfaces/AiProvider.md#chatstream)
