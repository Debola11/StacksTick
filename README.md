
# StacksTick: Decentralized Ticketing on Stacks

STX-ChainPass is a decentralized smart contract built using the Clarity language on the Stacks blockchain. It allows event organizers to mint, sell, transfer, and manage NFT-based event tickets in a trustless and transparent manner.

## ✨ Features

* ✅ **Mint Event Tickets**: Create new event tickets with metadata and capacity control.
* 💳 **Purchase Tickets**: Users can securely buy tickets using STX.
* 🔁 **Transfer Ownership**: Ticket owners can transfer their ticket NFTs to other users.
* 🚫 **Event Cancellation**: Organizers can cancel events and allow refunds.
* 💸 **Refund Support**: Ticket holders can get refunds if the event is canceled.
* 🔐 **Access Control**: Only the contract owner can mint or update events.

---

## 🛠️ Smart Contract Overview

### 🔐 Constants

```clarity
CONTRACT-OWNER         ;; Address of the contract deployer
ERR-NOT-OWNER          ;; Error for unauthorized access
ERR-TICKET-ALREADY-MINTED
ERR-TICKET-NOT-FOUND
ERR-UNAUTHORIZED-TRANSFER
ERR-INVALID-INPUT
ERR-CAPACITY-EXCEEDED
ERR-EVENT-ALREADY-CANCELLED
ERR-REFUND-FAILED
ERR-TICKETS-ALREADY-SOLD
ERR-INVALID-TRANSFER-RECIPIENT
```

---

## 🧠 Data Structures

### 🗺️ Maps

```clarity
ticket-metadata:
{
  ticket-id: string,
  event-name: string,
  event-date: string,
  ticket-price: uint,
  max-capacity: uint,
  current-sales: uint,
  is-cancelled: bool
}

event-ticket-holders:
{
  ticket-id: string,
  ticket-owner: principal
} -> bool
```

---

## 📤 Public Functions

### 🎟️ `mint-ticket`

Creates a new ticket type (NFT) for an event.

```clarity
(mint-ticket ticket-id event-name event-date ticket-price max-capacity)
```

* Only contract owner can call this.
* Checks for input validity and uniqueness.

---

### ✏️ `update-event-details`

Updates event name, date, and price **before any tickets are sold**.

```clarity
(update-event-details ticket-id new-event-name new-event-date new-ticket-price)
```

* Only callable by the contract owner.
* Cannot update if tickets are already sold.

---

### 💸 `purchase-ticket`

Allows users to buy a ticket if it hasn't reached max capacity.

```clarity
(purchase-ticket ticket-id)
```

* Transfers STX to the contract owner.
* Mints NFT ticket to the buyer.
* Updates ticket sales and holder registry.

---

### 🔁 `transfer-ticket`

Transfers ticket NFT to another principal.

```clarity
(transfer-ticket ticket-id new-owner)
```

* Sender must be the current owner.
* New owner must not be the contract owner.

---

### 🚫 `cancel-event`

Cancels the event and enables refunds.

```clarity
(cancel-event ticket-id)
```

* Only contract owner can cancel.
* Prevents further purchases or updates.

---

### 💵 `refund-ticket`

Refunds the ticket holder if the event was canceled.

```clarity
(refund-ticket ticket-id)
```

* Ticket must be owned by caller.
* Event must be canceled.
* NFT is burned and refund is issued.

---

## 🔍 Read-Only Functions

### 👤 `get-ticket-owner`

Returns the current owner of a ticket NFT.

```clarity
(get-ticket-owner ticket-id) => (optional principal)
```

---

### 📄 `get-ticket-metadata`

Fetches the metadata for a specific ticket.

```clarity
(get-ticket-metadata ticket-id) => (optional { event-name, event-date, ticket-price, ... })
```

---

## ✅ Validation (Private Functions)

* `(is-valid-event-name name)`
* `(is-valid-event-date date)`
* `(is-valid-ticket-price price)`
* `(is-valid-max-capacity capacity)`
* `(is-valid-principal addr)`

---

## 🔐 Access Control

* `CONTRACT-OWNER` is set to `tx-sender` at deploy time.
* Only the contract owner can:

  * Mint tickets
  * Update event details
  * Cancel events

---

## 📦 Deployment & Usage

### Requirements

* Clarity smart contract compatible environment (e.g. Clarinet, Hiro Explorer, Stacks CLI)
* STX tokens for testing and contract interactions

### Deployment

1. Clone the project
2. Use [Clarinet](https://docs.stacks.co/docs/clarity/clarinet/intro/) to test and deploy
3. Deploy with your desired network and contract name

```bash
clarinet deploy
```

---
