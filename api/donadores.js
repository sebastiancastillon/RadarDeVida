let donadores = []; 

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method === 'POST') {
    const { nombre, tipo_sangre, foto } = req.body;
    
    // Generar coordenadas aleatorias en Colima para la demo
    const lat = 19.2433 + (Math.random() - 0.5) * 0.02;
    const lng = -103.725 + (Math.random() - 0.5) * 0.02;

    const nuevoDonador = {
      id: Date.now(),
      nombre,
      tipo_sangre,
      foto,
      fecha: new Date().toLocaleString(),
      lat: lat,
      lng: lng
    };
    donadores.push(nuevoDonador);
    return res.status(201).json(nuevoDonador);
  }

  if (req.method === 'DELETE') {
    const { id } = req.query;
    donadores = donadores.filter(d => d.id.toString() !== id.toString());
    return res.status(200).json({ message: "Eliminado" });
  }

  if (req.method === 'GET') return res.status(200).json(donadores);
}
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
// Dentro de tu if (req.method === 'POST')
const nuevoDonador = {
  id: Date.now(),
  nombre,
  tipo_sangre,
  foto,
  fecha: new Date().toLocaleString(),
  // Si no vienen coordenadas de la App, ponemos unas de Colima Centro
  lat: req.body.lat || 19.2433, 
  lng: req.body.lng || -103.725
};

  }

  if (req.method === 'GET') return res.status(200).json(donadores);
