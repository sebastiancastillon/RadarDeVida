let donadores = []; 

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  // ELIMINAR UN DONANTE
  if (req.method === 'DELETE') {
    const { id } = req.query; // Recibe el ID desde la URL
    donadores = donadores.filter(d => d.id.toString() !== id.toString());
    return res.status(200).json({ message: "Eliminado correctamente" });
  }

  if (req.method === 'POST') {
    const nuevo = { ...req.body, id: Date.now(), fecha: new Date().toLocaleString() };
    donadores.push(nuevo);
    return res.status(201).json(nuevo);
  }

  if (req.method === 'GET') return res.status(200).json(donadores);
}