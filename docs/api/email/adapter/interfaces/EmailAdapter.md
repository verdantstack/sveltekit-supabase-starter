[**sveltekit-supabase-starter**](../../../README.md)

***

# Interface: EmailAdapter

The seam between the product and an email delivery provider.

## Remarks

Implementations are interchangeable; the product never imports a
specific provider SDK directly. See the adapter implementations for behavior.

## Properties

### name

> `readonly` **name**: `string`

A stable identifier for the adapter (e.g. `mock`, `resend`).

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
