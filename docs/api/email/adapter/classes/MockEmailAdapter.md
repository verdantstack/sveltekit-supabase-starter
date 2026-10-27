[**sveltekit-supabase-starter**](../../../README.md)

***

# Class: MockEmailAdapter

A no-op email adapter that logs to console instead of sending.
Used in development and testing; never sends real email.

## Implements

- [`EmailAdapter`](../interfaces/EmailAdapter.md)

## Constructors

### Constructor

> **new MockEmailAdapter**(): `MockEmailAdapter`

#### Returns

`MockEmailAdapter`

## Properties

### name

> `readonly` **name**: `"mock"` = `'mock'`

A stable identifier for the adapter (e.g. `mock`, `resend`).

#### Implementation of

[`EmailAdapter`](../interfaces/EmailAdapter.md).[`name`](../interfaces/EmailAdapter.md#name)

***

### sent

> `readonly` **sent**: [`EmailMessage`](../type-aliases/EmailMessage.md)[] = `[]`

## Methods

### send()

> **send**(`message`): `Promise`\<`string` \| `null`\>

Send a transactional email.

#### Parameters

##### message

[`EmailMessage`](../type-aliases/EmailMessage.md)

The email to send.

#### Returns

`Promise`\<`string` \| `null`\>

A provider message id, or null when delivery is not configured.

#### Implementation of

[`EmailAdapter`](../interfaces/EmailAdapter.md).[`send`](../interfaces/EmailAdapter.md#send)
