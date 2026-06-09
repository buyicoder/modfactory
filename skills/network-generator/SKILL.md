---
name: network-generator
description: Use when the user needs client-server data synchronization, custom packets, or network communication. Triggers on: "sync data between client and server", "send packet", "network communication", "S2C packet", "C2S packet", or dispatched by mc-mod-master.
---

# Network Generator

## Overview

Generates Fabric Networking API packets for client↔server data synchronization. Uses Payload-based API (1.21+). Covers block entity sync, HUD data, player capability sync, and custom events.

## Packet Type Selection

```
What needs to sync?
│
├── Server→Client (S2C) → Block entity data, HUD values, world events
├── Client→Server (C2S) → Player actions, key presses, GUI button clicks
├── Bidirectional → Chat-like messages, trade requests
└── Block entity sync → BlockEntityClientSerializable (auto-sync)
```

## Quick Template: S2C Packet (Server → Client)

```java
// common/network/ManaSyncPayload.java
public record ManaSyncPayload(int mana, int maxMana) implements CustomPayload {
    public static final CustomPayload.Id<ManaSyncPayload> ID =
        new CustomPayload.Id<>(Identifier.of(ExampleMod.MOD_ID, "mana_sync"));
    public static final PacketCodec<RegistryByteBuf, ManaSyncPayload> CODEC =
        PacketCodec.of(ManaSyncPayload::write, ManaSyncPayload::new);

    public ManaSyncPayload(RegistryByteBuf buf) {
        this(buf.readInt(), buf.readInt());
    }

    private void write(RegistryByteBuf buf) {
        buf.writeInt(mana);
        buf.writeInt(maxMana);
    }

    @Override
    public CustomPayload.Id<? extends CustomPayload> getId() {
        return ID;
    }

    // Send to all players tracking an entity
    public static void send(ServerPlayerEntity player) {
        PlayerManaData data = PlayerManaData.get(player);
        ServerPlayNetworking.send(player,
            new ManaSyncPayload(data.getMana(), data.getMaxMana()));
    }
}
```

### Receive S2C on Client
```java
// client/network/ClientNetworkHandler.java
public class ClientNetworkHandler {
    public static void register() {
        ClientPlayNetworking.registerGlobalReceiver(ManaSyncPayload.ID,
            (payload, context) -> {
                context.client().execute(() -> {
                    // Update client-side mana display
                    ClientManaData.set(payload.mana(), payload.maxMana());
                });
            });
    }
}
```

## Quick Template: C2S Packet (Client → Server)

```java
// common/network/UseSkillPayload.java
public record UseSkillPayload(Identifier skillId) implements CustomPayload {
    public static final CustomPayload.Id<UseSkillPayload> ID =
        new CustomPayload.Id<>(Identifier.of(ExampleMod.MOD_ID, "use_skill"));
    public static final PacketCodec<RegistryByteBuf, UseSkillPayload> CODEC =
        PacketCodec.of(UseSkillPayload::write, UseSkillPayload::new);

    public UseSkillPayload(RegistryByteBuf buf) {
        this(buf.readIdentifier());
    }

    private void write(RegistryByteBuf buf) {
        buf.writeIdentifier(skillId);
    }

    @Override
    public CustomPayload.Id<? extends CustomPayload> getId() {
        return ID;
    }

    // Send from client to server
    public static void send(Identifier skillId) {
        ClientPlayNetworking.send(new UseSkillPayload(skillId));
    }
}
```

### Receive C2S on Server
```java
// common/network/ServerNetworkHandler.java
public class ServerNetworkHandler {
    public static void register() {
        ServerPlayNetworking.registerGlobalReceiver(UseSkillPayload.ID,
            (payload, context) -> {
                ServerPlayerEntity player = context.player();
                Skill skill = SkillRegistry.get(payload.skillId()).orElse(null);
                if (skill != null) {
                    PlayerSkillData data = PlayerSkillData.get(player);
                    if (data.canUse(skill)) {
                        data.use(skill);
                        skill.use(player.getServerWorld(), player, data.getLevel(skill));
                    }
                }
            });
    }
}
```

## Registration

```java
// In ExampleMod.onInitialize():
ServerNetworkHandler.register();

// In ExampleModClient.onInitializeClient():
ClientNetworkHandler.register();
```

## Common Use Cases

| Use Case | Direction | Example |
|----------|-----------|---------|
| Block entity data | S2C | Sync cooking progress |
| Player stats (mana/energy) | S2C | HUD display |
| Entity spawn data | S2C | Sync mob state |
| Item use action | C2S | Use skill, cast spell |
| Key binding press | C2S | Open custom GUI |
| Chat message | C2S→S2C | Trade request |
| World event | S2C | Lightning strike, explosion |

## Packet Data Types (PacketCodec)

| Minecraft Type | Read | Write |
|---------------|------|-------|
| `int` | `readInt()` | `writeInt(n)` |
| `float` | `readFloat()` | `writeFloat(f)` |
| `boolean` | `readBoolean()` | `writeBoolean(b)` |
| `String` | `readString()` | `writeString(s)` |
| `Identifier` | `readIdentifier()` | `writeIdentifier(id)` |
| `BlockPos` | `readBlockPos()` | `writeBlockPos(pos)` |
| `ItemStack` | `ItemStack.PACKET_CODEC` | (use codec directly) |
| `CompoundTag` | `NbtIO.PACKET_CODEC` | (use codec directly) |

## Common Mistakes

| Symptom | Fix |
|---------|-----|
| "Unknown custom packet identifier" | Register receiver BEFORE sending any packets |
| Packet not received | Check registration is in correct initializer (client vs server) |
| ClassCastException | Ensure PacketCodec reads same types in same order as writes |
| "Payload too large" | Max packet size is ~2MB; split large data into chunks |
