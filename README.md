# rpa-ambulance

<div align="center">

![GitHub Release](https://img.shields.io/github/v/release/RP-Alpha/rpa-ambulance?style=for-the-badge&logo=github&color=blue)
![GitHub commits](https://img.shields.io/github/commits-since/RP-Alpha/rpa-ambulance/latest?style=for-the-badge&logo=git&color=green)
![License](https://img.shields.io/github/license/RP-Alpha/rpa-ambulance?style=for-the-badge&color=orange)
![Downloads](https://img.shields.io/github/downloads/RP-Alpha/rpa-ambulance/total?style=for-the-badge&logo=github&color=purple)

**Complete EMS Job System**

</div>

---

## ✨ Features

- 🏥 **Duty System** - Clock in/out at hospitals
- 💉 **Revive Mechanic** - CPR animation and resurrection
- 🩹 **Healing** - Treat wounds on nearby players
- 🚑 **Vehicle Garage** - Spawn ambulances

---

## 📥 Installation

1. Download the [latest release](https://github.com/RP-Alpha/rpa-ambulance/releases/latest)
2. Extract to your `resources` folder
3. Add to `server.cfg`:
   ```cfg
   ensure rpa-ambulance
   ```

---

## ⚙️ Configuration

Configure hospitals in `config.lua`:

```lua
Config.Hospitals = {
    ['pillbox'] = {
        label = "Pillbox Medical",
        coords = vector3(x, y, z)
    }
}
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/RP-Alpha">RP-Alpha</a></sub>
</div>
