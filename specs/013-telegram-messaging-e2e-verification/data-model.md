# Data Model - Telegram Messaging Gateway

## Telegram Update Event
- `update_id`: Integer
- `message`:
  - `message_id`: Integer
  - `from`: `{ id: Integer, is_bot: Boolean, first_name: String }`
  - `chat`: `{ id: Integer, type: String }`
  - `date`: Integer (Unix timestamp)
  - `text`: String

## Status Response Payload
- `status`: String (`OK`)
- `uptime`: String
- `disk_space_used`: String
- `disk_space_available`: String
- `container_status`: String
