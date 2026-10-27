[**sveltekit-supabase-starter**](../../../README.md)

***

# Class: ResendEmailAdapter

Email adapter backed by the Resend HTTP API.

## Implements

- [`EmailAdapter`](../../adapter/interfaces/EmailAdapter.md)

## Constructors

### Constructor

> **new ResendEmailAdapter**(`opts`): `ResendEmailAdapter`

Create a Resend adapter.

#### Parameters

##### opts

Configuration; falls back to env vars `RESEND_API_KEY`/`RESEND_FROM`.

###### apiKey?

`string`

###### from?

`string`

#### Returns

`ResendEmailAdapter`

## Properties

### name

> `readonly` **name**: `"resend"` = `'resend'`

A stable identifier for the adapter (e.g. `mock`, `resend`).

#### Implementation of

[`EmailAdapter`](../../adapter/interfaces/EmailAdapter.md).[`name`](../../adapter/interfaces/EmailAdapter.md#name)

## Methods

### send()

> **send**(`message`): `Promise`\<`string` \| `null`\>

Send an email via Resend.

#### Parameters

##### message

[`EmailMessage`](../../adapter/type-aliases/EmailMessage.md)

Email to send.

#### Returns

`Promise`\<`string` \| `null`\>

Provider message id, or `null` when unconfigured/failed.

#### Implementation of

[`EmailAdapter`](../../adapter/interfaces/EmailAdapter.md).[`send`](../../adapter/interfaces/EmailAdapter.md#send)
