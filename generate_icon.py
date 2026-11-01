from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon():
    size = 1024
    img = Image.new("RGBA", (size, size), (15, 23, 42, 255)) # slate-900
    draw = ImageDraw.Draw(img)

    # 1. Subtle Radial / Circular Glow in background
    for r in range(480, 100, -10):
        alpha = int(40 * (1.0 - r / 480.0))
        draw.ellipse([512 - r, 512 - r, 512 + r, 512 + r], fill=(245, 158, 11, alpha))

    # 2. Outer Golden Crest / Ring
    draw.ellipse([100, 100, 924, 924], outline=(245, 158, 11, 220), width=16)
    draw.ellipse([116, 116, 908, 908], outline=(251, 191, 36, 120), width=4)

    # 3. Inner Dark Badge
    draw.ellipse([124, 124, 900, 900], fill=(24, 34, 53, 255))

    # Center coords
    cx, cy = 512, 480

    # 4. Draw Gourmet Burger
    # --- Bottom Bun ---
    # Draw bottom rounded bun: (320, 620) to (704, 690)
    draw.rounded_rectangle([330, 620, 694, 690], radius=30, fill=(217, 119, 6), outline=(180, 83, 9), width=6)

    # --- Lettuce (Green curly layer) ---
    for x in range(315, 710, 32):
        draw.ellipse([x - 12, 595, x + 36, 635], fill=(34, 197, 94, 255), outline=(22, 163, 74, 255), width=4)

    # --- Juicy Grilled Patty ---
    draw.rounded_rectangle([310, 555, 714, 610], radius=24, fill=(101, 46, 22), outline=(78, 32, 12), width=6)
    # Grill marks
    for gx in range(350, 680, 50):
        draw.line([gx, 565, gx + 25, 600], fill=(60, 24, 8), width=8)

    # --- Melted Cheese (Cheddar Golden Yellow with Drips) ---
    cheese_pts = [
        (300, 545), (724, 545),
        (710, 570), (660, 575), (630, 615), (610, 575), # drip 1
        (540, 570), (510, 625), (480, 570),             # big drip 2
        (420, 575), (390, 610), (370, 575),             # drip 3
        (300, 570)
    ]
    draw.polygon(cheese_pts, fill=(245, 158, 11), outline=(217, 119, 6))

    # --- Tomato Slices (Red) ---
    draw.rounded_rectangle([325, 505, 505, 545], radius=16, fill=(239, 68, 68), outline=(185, 28, 28), width=5)
    draw.rounded_rectangle([515, 505, 695, 545], radius=16, fill=(239, 68, 68), outline=(185, 28, 28), width=5)

    # --- Top Bun (Brioche Dome) ---
    draw.chord([310, 290, 714, 550], start=180, end=0, fill=(245, 158, 11), outline=(180, 83, 9), width=8)

    # Top Bun Highlight
    draw.chord([340, 310, 684, 490], start=190, end=350, fill=(251, 191, 36, 120))

    # --- Sesame Seeds (White / Cream droplets on top bun) ---
    sesame_positions = [
        (420, 360), (512, 340), (600, 365),
        (380, 400), (460, 395), (550, 390), (640, 410),
        (410, 445), (500, 440), (590, 445), (450, 470), (560, 470)
    ]
    for sx, sy in sesame_positions:
        draw.ellipse([sx - 7, sy - 4, sx + 7, sy + 4], fill=(254, 243, 199))

    # 5. Lower Banner for "بركر ادم"
    # Ribbon Banner
    banner_box = [230, 750, 794, 860]
    draw.rounded_rectangle(banner_box, radius=32, fill=(220, 38, 38), outline=(245, 158, 11), width=8)

    # Add Stars around banner
    def draw_star(center_x, center_y, radius, color):
        points = []
        for i in range(10):
            r = radius if i % 2 == 0 else radius * 0.45
            angle = i * math.pi / 5 - math.pi / 2
            points.append((center_x + r * math.cos(angle), center_y + r * math.sin(angle)))
        draw.polygon(points, fill=color)

    draw_star(280, 805, 22, (251, 191, 36))
    draw_star(744, 805, 22, (251, 191, 36))

    # Try loading Arial / Segoe / Apple font, or draw clean geometric Arabic text
    # Let's write text or stylized brand
    font = None
    for font_path in ["C:\\Windows\\Fonts\\arialbd.ttf", "C:\\Windows\\Fonts\\segoeui.ttf", "C:\\Windows\\Fonts\\tahoma.ttf"]:
        try:
            font = ImageFont.truetype(font_path, 60)
            break
        except:
            pass

    text = "ADAM BURGER"
    if font:
        bbox = draw.textbbox((0, 0), text, font=font)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        draw.text(((size - w) / 2, 805 - h / 2 - 4), text, fill=(255, 255, 255), font=font)
    else:
        draw.rectangle([350, 790, 674, 820], fill=(255, 255, 255))

    out_path = r"C:\Users\baraa\Desktop\BurgerAdam-iOS\BurgerAdam\Assets.xcassets\AppIcon.appiconset\AppIcon-1024.png"
    img.save(out_path, "PNG")
    print("Icon generated at:", out_path)

if __name__ == "__main__":
    create_app_icon()
