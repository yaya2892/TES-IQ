<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ujian Proctored + Monitoring Kamera</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; text-align: center; padding: 20px; }
        .container { max-width: 600px; background: white; padding: 30px; margin: auto; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        #video { width: 100%; max-width: 250px; border-radius: 12px; display: none; margin-bottom: 20px; border: 3px solid #ff4757; transform: scaleX(-1); }
        .hidden { display: none; }
        button { padding: 12px 25px; cursor: pointer; background: #007bff; color: white; border: none; border-radius: 8px; font-weight: bold; font-size: 16px; transition: 0.3s; }
        button:hover { background: #0056b3; transform: translateY(-2px); }
        .question { text-align: left; margin-top: 20px; padding: 15px; background: #f9f9f9; border-radius: 10px; border-left: 5px solid #007bff; }
        #timer { font-size: 20px; color: #ff4757; font-weight: bold; margin-bottom: 10px; }
    </style>
</head>
<body>

    <div class="container">
        <video id="video" autoplay playsinline></video>
        <canvas id="canvas" style="display:none;"></canvas>

        <div id="intro">
            <h1 style="margin-bottom: 10px;">Tes IQ Dasar (Proctored)</h1>
            <p>Sistem akan mengambil foto secara otomatis untuk validasi peserta.</p>
            <p style="color: #666;">Waktu: 120 Detik</p>
            <hr>
            <button id="startBtn">MULAI UJIAN SEKARANG</button>
        </div>

        <form id="quizForm" class="hidden" action="https://formspree.io/f/mykbgrlk" method="POST">
            <div id="timer">Sisa Waktu: <span id="countdown">120</span>s</div>
            
            <input type="hidden" name="FOTO_PESERTA" id="foto_input">

            <div class="question">
                <p>1. Apa Ibukota Indonesia saat ini (Tahun 2026)?</p>
                <input type="text" name="Soal_1" required placeholder="Jawaban anda...">
            </div>

            <div class="question">
                <p>2. 10 + 10 x 0 = ...</p>
                <input type="number" name="Soal_2" required>
            </div>

            <div class="question">
                <p>3. Jika 2=4, 3=9, 4=16, maka 5=...?</p>
                <input type="number" name="Soal_3" required>
            </div>

            <div class="question">
                <p>4. Mana yang tidak termasuk kelompoknya? (Apel, Jeruk, Wortel, Pisang)</p>
                <input type="text" name="Soal_4" required>
            </div>

            <div class="question">
                <p>5. Lawan kata dari "TINGGI" adalah...</p>
                <input type="text" name="Soal_5" required>
            </div>

            <br>
            <button type="submit" id="submitBtn">KIRIM SEMUA JAWABAN</button>
        </form>

        <div id="status" class="hidden">
            <h3>Sedang memproses & mengirim data...</h3>
            <p>Mohon jangan tutup halaman ini.</p>
        </div>
    </div>

    <script>
        const video = document.getElementById('video');
        const canvas = document.getElementById('canvas');
        const fotoInput = document.getElementById('foto_input');
        const quizForm = document.getElementById('quizForm');
        const countdownEl = document.getElementById('countdown');

        let timeLeft = 120;

        // 1. Fungsi Jalankan Kamera & Mulai Ujian
        document.getElementById('startBtn').onclick = async () => {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ video: true });
                video.srcObject = stream;
                video.style.display = 'inline-block';
                document.getElementById('intro').classList.add('hidden');
                quizForm.classList.remove('hidden');

                // Jalankan Timer
                const timerInterval = setInterval(() => {
                    timeLeft--;
                    countdownEl.innerText = timeLeft;
                    if (timeLeft <= 0) {
                        clearInterval(timerInterval);
                        quizForm.requestSubmit(); // Auto kirim kalau waktu habis
                    }
                }, 1000);

            } catch (err) {
                alert("Wajib izinkan akses kamera untuk memulai ujian ini!");
            }
        };

        // 2. Fungsi Ambil Foto & Kirim ke Formspree
        quizForm.onsubmit = async (e) => {
            e.preventDefault();
            document.getElementById('status').classList.remove('hidden');
            quizForm.classList.add('hidden');

            // Ambil Snapshot dari video
            const context = canvas.getContext('2d');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            context.drawImage(video, 0, 0, canvas.width, canvas.height);

            // Ubah foto jadi teks (Base64)
            const dataDataURL = canvas.toDataURL('image/png');
            fotoInput.value = dataDataURL;

            // Kirim via AJAX biar nggak pindah halaman
            const formData = new FormData(quizForm);
            fetch(quizForm.action, {
                method: 'POST',
                body: formData,
                headers: { 'Accept': 'application/json' }
            }).then(response => {
                if (response.ok) {
                    alert("Ujian Selesai! Jawaban dan foto pengawas berhasil dikirim.");
                    window.location.reload();
                } else {
                    alert("Ada masalah pengiriman. Coba lagi.");
                    document.getElementById('status').classList.add('hidden');
                    quizForm.classList.remove('hidden');
                }
            });
        };
    </script>
</body>
</html>
