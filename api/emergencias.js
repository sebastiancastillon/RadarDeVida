// Memoria temporal para la emergencia activa
let emergenciaActiva = null; 

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  // GET: Tu Panel Web pregunta "¿Hay alguna emergencia y cuántos van en camino?"
  if (req.method === 'GET') {
    return res.status(200).json(emergenciaActiva || { activa: false });
  }

  // POST: Tu Panel Web crea una nueva alerta
  if (req.method === 'POST') {
    const { tipo_sangre, hospital } = req.body;
    
    emergenciaActiva = {
        id: Date.now(),
        tipo_sangre: tipo_sangre || "Cualquiera",
        hospital: hospital || "Hospital Regional de Colima",
        donadores_en_camino: 0,
        activa: true
    };
    
    // Más adelante, aquí conectaremos OneSignal para mandar las Notificaciones Push
    
    return res.status(201).json(emergenciaActiva);
  }

  // PUT: El donante presiona "Voy en camino" en Flutter
  if (req.method === 'PUT') {
    if (emergenciaActiva && emergenciaActiva.activa) {
        emergenciaActiva.donadores_en_camino += 1;
        return res.status(200).json(emergenciaActiva);
    }
    return res.status(400).json({ error: "No hay ninguna emergencia activa en este momento" });
  }

  // DELETE: Apagar la alerta desde el panel web
  if (req.method === 'DELETE') {
    emergenciaActiva = null;
    return res.status(200).json({ message: "Emergencia finalizada" });
  }
}