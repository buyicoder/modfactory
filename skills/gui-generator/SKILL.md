---
name: gui-generator
description: Use when the user needs custom GUI screens, container menus, buttons, progress bars, or HUD overlays. Triggers on: "add a GUI", "create a screen", "make a container", "add a button", "custom inventory", "HUD overlay", or dispatched by mc-mod-master.
---

# GUI Generator

## Overview

Generates complete GUI systems: ScreenHandler (server-side container logic), Screen (client-side rendering), and HUD overlay elements. Follows Minecraft's split client/server GUI architecture.

## GUI Type Selection

```
What kind of GUI?
│
├── Simple container (chest-like) → GenericContainerScreenHandler
├── Custom machine GUI → ScreenHandler + Screen + BlockEntity
├── Button/dialog screen → Screen (no BlockEntity)
├── Progress bar → ScreenHandler property delegate
├── HUD overlay → HudRenderCallback
├── Recipe book GUI → RecipeBookScreen
└── Tabbed GUI → Multiple screens with tab navigation
```

## Quick Template: Machine GUI (3 files)

### File 1: ScreenHandler (Server)
```java
// common/gui/<Name>ScreenHandler.java
public class RubyFurnaceScreenHandler extends ScreenHandler {
    private final Inventory inventory;

    // Client constructor (called by Screen)
    public RubyFurnaceScreenHandler(int syncId, PlayerInventory playerInventory) {
        this(syncId, playerInventory, new SimpleInventory(3));
    }

    // Server constructor
    public RubyFurnaceScreenHandler(int syncId, PlayerInventory playerInventory,
                                     Inventory inventory) {
        super(ModScreenHandlers.RUBY_FURNACE, syncId);
        this.inventory = inventory;
        inventory.onOpen(playerInventory.player);

        // Input slot (0)
        this.addSlot(new Slot(inventory, 0, 56, 35));
        // Fuel slot (1)
        this.addSlot(new FurnaceFuelSlot(this, inventory, 1, 56, 53));
        // Output slot (2)
        this.addSlot(new FurnaceOutputSlot(playerInventory.player, inventory, 2, 116, 35));

        // Player inventory (hotbar + main)
        for (int row = 0; row < 3; row++) {
            for (int col = 0; col < 9; col++) {
                this.addSlot(new Slot(playerInventory, col + row * 9 + 9, 8 + col * 18, 84 + row * 18));
            }
        }
        for (int col = 0; col < 9; col++) {
            this.addSlot(new Slot(playerInventory, col, 8 + col * 18, 142));
        }
    }

    @Override
    public ItemStack quickMove(PlayerEntity player, int slot) {
        // Shift-click logic: move items between container and player inventory
        ItemStack stack = ItemStack.EMPTY;
        Slot s = this.slots.get(slot);
        if (s != null && s.hasStack()) {
            ItemStack slotStack = s.getStack();
            stack = slotStack.copy();
            if (slot < 3) {
                if (!this.insertItem(slotStack, 3, 39, true)) return ItemStack.EMPTY;
            } else if (!this.insertItem(slotStack, 0, 3, false)) return ItemStack.EMPTY;
            if (slotStack.isEmpty()) s.setStack(ItemStack.EMPTY);
            else s.markDirty();
        }
        return stack;
    }

    @Override
    public boolean canUse(PlayerEntity player) {
        return this.inventory.canPlayerUse(player);
    }
}
```

### File 2: Screen (Client)
```java
// client/gui/<Name>Screen.java
public class RubyFurnaceScreen extends HandledScreen<RubyFurnaceScreenHandler> {
    private static final Identifier TEXTURE =
        Identifier.of(ExampleMod.MOD_ID, "textures/gui/ruby_furnace.png");

    public RubyFurnaceScreen(RubyFurnaceScreenHandler handler, PlayerInventory inventory, Text title) {
        super(handler, inventory, title);
        this.backgroundHeight = 166;
        this.playerInventoryTitleY = this.backgroundHeight - 94;
    }

    @Override
    protected void drawBackground(DrawContext context, float delta, int mouseX, int mouseY) {
        RenderSystem.setShader(GameRenderer::getPositionTexProgram);
        RenderSystem.setShaderColor(1.0F, 1.0F, 1.0F, 1.0F);
        int x = (this.width - this.backgroundWidth) / 2;
        int y = (this.height - this.backgroundHeight) / 2;
        context.drawTexture(TEXTURE, x, y, 0, 0, this.backgroundWidth, this.backgroundHeight);

        // Draw progress arrow
        if (handler.isBurning()) {
            int progress = handler.getCookProgress(24);
            context.drawTexture(TEXTURE, x + 79, y + 34, 176, 14, progress + 1, 16);
        }
        // Draw fuel bar
        int fuel = handler.getFuelProgress(14);
        context.drawTexture(TEXTURE, x + 56, y + 36 + 12 - fuel, 176, 12 - fuel, 14, fuel + 1);
    }

    @Override
    public void render(DrawContext context, int mouseX, int mouseY, float delta) {
        renderBackground(context, mouseX, mouseY, delta);
        super.render(context, mouseX, mouseY, delta);
        drawMouseoverTooltip(context, mouseX, mouseY);
    }
}
```

### File 3: Registration
```java
// common/registry/ModScreenHandlers.java
public class ModScreenHandlers {
    public static final ScreenHandlerType<RubyFurnaceScreenHandler> RUBY_FURNACE =
        Registry.register(Registries.SCREEN_HANDLER,
            Identifier.of(ExampleMod.MOD_ID, "ruby_furnace"),
            new SimpleScreenHandlerType<>(RubyFurnaceScreenHandler::new));
}

// Client registration in onInitializeClient:
HandledScreens.register(ModScreenHandlers.RUBY_FURNACE, RubyFurnaceScreen::new);
```

## BlockEntity + ScreenHandler Bridge

```java
// common/block/entity/<Name>BlockEntity.java
public class RubyFurnaceBlockEntity extends BlockEntity
        implements NamedScreenHandlerFactory, ImplementedInventory {
    // ... inventory implementation ...

    @Override
    public ScreenHandler createMenu(int syncId, PlayerInventory playerInventory, PlayerEntity player) {
        return new RubyFurnaceScreenHandler(syncId, playerInventory, this);
    }

    @Override
    public Text getDisplayName() {
        return Text.translatable("container.modid.ruby_furnace");
    }
}

// In the Block class:
@Override
public ActionResult onUse(BlockState state, World world, BlockPos pos,
        PlayerEntity player, BlockInteractionHitResult hit) {
    if (!world.isClient) {
        player.openHandledScreen(state.createScreenHandlerFactory(world, pos));
    }
    return ActionResult.SUCCESS;
}
```

## Property Delegates (Progress Bars)

```java
// In ScreenHandler:
private final PropertyDelegate propertyDelegate;

// Constructor:
this.propertyDelegate = new ArrayPropertyDelegate(4); // 4 properties
this.addProperties(propertyDelegate);

// In BlockEntity tick():
propertyDelegate.set(0, cookTime);
propertyDelegate.set(1, cookTimeTotal);
propertyDelegate.set(2, fuelTime);
propertyDelegate.set(3, fuelTimeTotal);

// In Screen:
int progress = handler.getProperty(0);
int maxProgress = handler.getProperty(1);
```

## HUD Overlay

```java
// client/hud/<Name>HudOverlay.java
public class ManaHudOverlay {
    public static void register() {
        HudRenderCallback.EVENT.register((drawContext, tickDelta) -> {
            MinecraftClient client = MinecraftClient.getInstance();
            if (client.player == null) return;

            int mana = PlayerManaData.get(client.player).getMana();
            int x = 10;
            int y = client.getWindow().getScaledHeight() - 50;
            drawContext.drawText(client.textRenderer,
                "Mana: " + mana + "/100",
                x, y, 0x4488FF, true);
        });
    }
}
```

## Auto-Generated Files Per GUI

| GUI Type | Files |
|----------|-------|
| Simple container | ScreenHandler.java + registration |
| Machine GUI | ScreenHandler.java + Screen.java + BlockEntity + Block + registration × 3 |
| HUD overlay | HudOverlay.java + event register |
| Recipe book GUI | ScreenHandler + Screen + RecipeBookScreen + recipe book category |

## GUI Texture Requirements

- 256×256 PNG with GUI texture atlas
- Standard layout: 176×166 background
- Progress arrows at (176, 14) on atlas
- Fuel/energy bars at (176, 0) on atlas
- Player inventory slots are standard and don't need custom textures
