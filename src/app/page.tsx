const modules = [
  { code: "01", title: "Penerimaan peserta didik", detail: "PPDB/SPMB, prospek, formulir, dan tindak lanjut keluarga." },
  { code: "02", title: "Data sekolah & keluarga", detail: "Satuan pendidikan, peserta didik, wali, rombel, dan tahun ajaran." },
  { code: "03", title: "Akademik & pelaporan", detail: "Kurikulum per jenjang, presensi, observasi, dan draf laporan dengan persetujuan manusia." },
  { code: "04", title: "Operasional & keuangan", detail: "Tagihan, pembayaran, pengeluaran, transportasi, dan audit transaksi." },
  { code: "05", title: "SDM & penggajian", detail: "Pegawai, penugasan, kehadiran, komponen gaji, dan persetujuan." },
  { code: "06", title: "Interoperabilitas", detail: "Impor/ekspor data tervalidasi dan integrasi Dapodik sesuai akses resmi." },
];

export default function Home() {
  return <main className="shell">
    <header className="topbar"><a className="brand" href="/">S<span>OS</span></a><span className="top-label">EDUCATION OPERATING SYSTEM</span><span className="status"><i /> Fondasi proyek</span></header>
    <section className="hero"><p className="eyebrow">SATU PLATFORM · BERBAGAI JENJANG</p><h1>Operasional pendidikan,<br /><em>terhubung dalam satu sistem.</em></h1><p className="intro">School OS dirancang untuk membantu satuan pendidikan mengelola penerimaan, data keluarga, akademik, operasional, dan administrasi dengan alur yang dapat disesuaikan menurut jenjang.</p><div className="hero-note"><span className="note-mark">✳</span><div><strong>Dibangun bertahap, dengan data yang terlindungi.</strong><p>Fondasi ini belum terhubung ke database produksi. Integrasi dan akses data baru diaktifkan setelah konfigurasi serta kontrol keamanannya diverifikasi.</p></div></div></section>
    <section className="modules"><div className="section-head"><div><p className="eyebrow">RUANG LINGKUP</p><h2>Modul inti School OS</h2></div><span className="counter">06 AREA</span></div><div className="module-grid">{modules.map((m) => <article className="module" key={m.code}><span className="module-code">{m.code}</span><h3>{m.title}</h3><p>{m.detail}</p><span className="arrow">↗</span></article>)}</div></section>
    <footer><span>School OS · Project foundation</span><span>Keamanan data adalah fondasi, bukan fitur tambahan.</span></footer>
  </main>;
}
