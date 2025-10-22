document.addEventListener("DOMContentLoaded", () => {
  const container = document.querySelector(".main-container");
  const createBtn = document.querySelector(".create-border");
  const modelInput = document.querySelector(".npc-model-input");
  const nameInput = document.querySelector(".npc-name-input");
  const animNameInput = document.querySelector(".anim-name-input");

  // Menerima event dari client.lua
  window.addEventListener("message", (event) => {
    if (event.data.type === "openUI") {
      container.style.display = "block";

      // Fokus ke kolom animasi supaya langsung bisa diketik
      setTimeout(() => {
        animNameInput.focus();
      }, 150);
    }
  });

  // Tombol CREATE
  createBtn.addEventListener("click", () => {
    const npcData = {
      model: modelInput.value.trim(),
      name: nameInput.value.trim(),
      animDict: "", // otomatis diambil di client.lua
      animName: animNameInput.value.trim(),
    };

    // Kirim data ke client.lua
    fetch(`https://${GetParentResourceName()}/createNPC`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(npcData),
    });

    // Tutup UI dan kembalikan fokus ke game
    container.style.display = "none";
    fetch(`https://${GetParentResourceName()}/toggleCursor`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ show: false }),
    });
  });

  // Tutup dengan ESC
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      container.style.display = "none";
      fetch(`https://${GetParentResourceName()}/toggleCursor`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ show: false }),
      });
    }
  });
});
