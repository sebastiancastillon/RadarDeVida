// Variable en memoria (se limpia si Vercel se apaga)
let donadores = []; 

export default function handler(req, res) {
  // --- ESTO ES LO QUE ARREGLA EL ERROR DE SUBIDA (CORS) ---
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*'); // Permite cualquier origen
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');

  // Responder rápido a la verificación de conexión
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  // Lógica para guardar donador
  if (req.method === 'POST') {
    const { nombre, tipo_sangre, foto } = req.body;
    const nuevoDonador = {
      id: Date.now(),
      nombre,
      tipo_sangre,
      foto,
      fecha: new Date().toLocaleString()
    };
    donadores.push(nuevoDonador);
    return res.status(201).json(nuevoDonador);
  }

  // Lógica para ver donadores
  if (req.method === 'GET') {
    return res.status(200).json(donadores);
  }
}