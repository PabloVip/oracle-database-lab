# scripts/lab5/04-dibujar-curva.py — reto de la Parte E: curvas del punto de equilibrio desde la evidencia 04
# Uso (requiere matplotlib): python3 scripts/lab5/04-dibujar-curva.py docs/bitacora/lab5/curva-equilibrio.png
import re, sys, glob
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
log = sorted(glob.glob("docs/bitacora/lab5/evidencia/script/*_04-agrupamiento-equilibrio.script.log"))[-1]
k, good, bad, full = [], [], [], []
for line in open(log, encoding="utf-8", errors="replace"):
    m = re.match(r"^\s*([\d.]+) %\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s", line)
    if m:
        k.append(float(m[1])); good.append(int(m[3])); bad.append(int(m[4])); full.append(int(m[5]))
INK, INK2, GRID, SURF = "#0b0b0b", "#52514e", "#e4e3df", "#fcfcfb"
fig, ax = plt.subplots(figsize=(9, 5.2), dpi=150, facecolor=SURF)
ax.set_facecolor(SURF)
ax.plot(k, good, color="#2a78d6", lw=2, marker="o", ms=5, label="Índice con CF bueno (IX_PED_FECHA)")
ax.plot(k, bad, color="#eb6834", lw=2, marker="s", ms=5, label="Índice con CF malo (IX_PED_CLIENTE)")
ax.plot(k, full, color=INK2, lw=1.5, ls="--", label="Tabla entera (full scan)")
ax.set_xscale("log"); ax.set_yscale("log")
ax.axvspan(0.1, 0.2, color="#eda100", alpha=0.15, lw=0)
ax.text(0.141, 2.2e5, "el optimizador\ncambia a full scan\n(0,1–0,2 %)", ha="center", va="top", fontsize=8, color=INK2)
ax.annotate("CF malo cruza la tabla\n≈ 0,53 % (1/bfr)", xy=(0.53, 5232), xytext=(0.012, 1.6e4),
            fontsize=8, color=INK, arrowprops=dict(arrowstyle="-", color=INK2, lw=0.8))
ax.annotate("CF bueno cruza la tabla\n≈ 66 %", xy=(66, 5232), xytext=(8, 30000),
            fontsize=8, color=INK, arrowprops=dict(arrowstyle="-", color=INK2, lw=0.8))
ax.set_xlabel("k = % de pedidos leídos (escala logarítmica)", color=INK)
ax.set_ylabel("Lecturas lógicas (escala logarítmica)", color=INK)
ax.set_title("Punto de equilibrio índice frente a recorrido completo · TiendaSur.PEDIDO", color=INK, fontsize=11, loc="left")
ax.grid(True, which="major", color=GRID, lw=0.6); ax.set_axisbelow(True)
for s in ("top", "right"): ax.spines[s].set_visible(False)
for s in ("left", "bottom"): ax.spines[s].set_color(GRID)
ax.tick_params(colors=INK2, labelsize=8)
ax.legend(frameon=False, fontsize=8, loc="upper left", labelcolor=INK)
fig.tight_layout(); fig.savefig(sys.argv[1], facecolor=SURF)
print(len(k), "puntos")
