import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastStringId = 0;
const stringData = new Map();
const stringOwners = new Map();

// Simulated contract functions
function mintCosmicString(coordinates: string, length: number, energyDensity: number, sender: string) {
  if (sender !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const stringId = ++lastStringId;
  stringData.set(stringId, {
    discoverer: sender,
    coordinates,
    length,
    energyDensity,
    discoveryTimestamp: Date.now()
  });
  stringOwners.set(stringId, sender);
  return stringId;
}

function transferCosmicString(stringId: number, sender: string, recipient: string) {
  if (stringOwners.get(stringId) !== sender) throw new Error('Not authorized');
  stringOwners.set(stringId, recipient);
  return true;
}

describe('Cosmic String NFT Contract', () => {
  beforeEach(() => {
    lastStringId = 0;
    stringData.clear();
    stringOwners.clear();
  });
  
  it('should mint a cosmic string NFT', () => {
    const id = mintCosmicString('23.45,67.89', 1000000, 500, 'CONTRACT_OWNER');
    expect(id).toBe(1);
    const cosmicString = stringData.get(id);
    expect(cosmicString.coordinates).toBe('23.45,67.89');
    expect(cosmicString.length).toBe(1000000);
    expect(cosmicString.energyDensity).toBe(500);
    expect(stringOwners.get(id)).toBe('CONTRACT_OWNER');
  });
  
  it('should not allow unauthorized minting', () => {
    expect(() => mintCosmicString('23.45,67.89', 1000000, 500, 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should transfer cosmic string ownership', () => {
    const id = mintCosmicString('23.45,67.89', 1000000, 500, 'CONTRACT_OWNER');
    expect(transferCosmicString(id, 'CONTRACT_OWNER', 'new_owner')).toBe(true);
    expect(stringOwners.get(id)).toBe('new_owner');
  });
  
  it('should not allow unauthorized transfers', () => {
    const id = mintCosmicString('23.45,67.89', 1000000, 500, 'CONTRACT_OWNER');
    expect(() => transferCosmicString(id, 'unauthorized_user', 'new_owner')).toThrow('Not authorized');
  });
});

