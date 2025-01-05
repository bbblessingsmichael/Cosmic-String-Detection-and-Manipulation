import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastTechniqueId = 0;
const techniques = new Map();
const techniqueOwners = new Map();
const balances = new Map();

// Simulated contract functions
function createTechnique(name: string, description: string, price: number, creator: string) {
  const techniqueId = ++lastTechniqueId;
  techniques.set(techniqueId, {
    creator,
    name,
    description,
    price,
    status: 'active'
  });
  techniqueOwners.set(`${techniqueId}-${creator}`, 1);
  return techniqueId;
}

function buyTechnique(techniqueId: number, buyer: string) {
  const technique = techniques.get(techniqueId);
  if (!technique || technique.status !== 'active') throw new Error('Invalid technique');
  if ((balances.get(buyer) || 0) < technique.price) throw new Error('Insufficient balance');
  balances.set(buyer, (balances.get(buyer) || 0) - technique.price);
  balances.set(technique.creator, (balances.get(technique.creator) || 0) + technique.price);
  techniqueOwners.set(`${techniqueId}-${buyer}`, (techniqueOwners.get(`${techniqueId}-${buyer}`) || 0) + 1);
  return true;
}

function updateTechniqueStatus(techniqueId: number, newStatus: string, sender: string) {
  const technique = techniques.get(techniqueId);
  if (!technique) throw new Error('Invalid technique');
  if (sender !== technique.creator) throw new Error('Not authorized');
  technique.status = newStatus;
  techniques.set(techniqueId, technique);
  return true;
}

describe('Manipulation Technique Marketplace Contract', () => {
  beforeEach(() => {
    lastTechniqueId = 0;
    techniques.clear();
    techniqueOwners.clear();
    balances.clear();
  });
  
  it('should create a new technique', () => {
    const id = createTechnique('String Vibration', 'Manipulate cosmic string vibrations', 1000, 'creator1');
    expect(id).toBe(1);
    const technique = techniques.get(id);
    expect(technique.name).toBe('String Vibration');
    expect(technique.status).toBe('active');
    expect(techniqueOwners.get(`${id}-creator1`)).toBe(1);
  });
  
  it('should allow buying a technique', () => {
    const id = createTechnique('String Vibration', 'Manipulate cosmic string vibrations', 1000, 'creator1');
    balances.set('buyer1', 2000);
    expect(buyTechnique(id, 'buyer1')).toBe(true);
    expect(balances.get('buyer1')).toBe(1000);
    expect(balances.get('creator1')).toBe(1000);
    expect(techniqueOwners.get(`${id}-buyer1`)).toBe(1);
  });
  
  it('should not allow buying with insufficient balance', () => {
    const id = createTechnique('String Vibration', 'Manipulate cosmic string vibrations', 1000, 'creator1');
    balances.set('buyer1', 500);
    expect(() => buyTechnique(id, 'buyer1')).toThrow('Insufficient balance');
  });
  
  it('should update technique status', () => {
    const id = createTechnique('String Vibration', 'Manipulate cosmic string vibrations', 1000, 'creator1');
    expect(updateTechniqueStatus(id, 'inactive', 'creator1')).toBe(true);
    expect(techniques.get(id).status).toBe('inactive');
  });
  
  it('should not allow unauthorized status updates', () => {
    const id = createTechnique('String Vibration', 'Manipulate cosmic string vibrations', 1000, 'creator1');
    expect(() => updateTechniqueStatus(id, 'inactive', 'unauthorized_user')).toThrow('Not authorized');
  });
});

