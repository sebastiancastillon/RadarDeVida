let donadores = []; // Memoria temporal

export default function handler(req, res) {
  // Permitir que Flutter se conecte desde cualquier lugar (CORS)
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method === 'POST') {
    const nuevoDonador = {
      id: Date.now(),
      nombre: req.body.nombre,
      tipo: req.body.tipo_sangre,
      foto: req.body.foto, // Base64
      fecha: new Date().toLocaleString()
    };
    donadores.push(nuevoDonador);
    return res.status(201).json(nuevoDonador);
  }

  if (req.method === 'GET') {
    return res.status(200).json(donadores);
  }
}