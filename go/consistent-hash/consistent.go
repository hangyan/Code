// Package consitent provides a consitent hashing function.

package consitent

import (
	"errors"
	"hash/crc32"
	"sort"
	"strconv"
	"sync"
)

type uints []uint32

// Len returns the Length of the uints array.
func (x uints) Len() int { return len(x) }

// Less returns true if element i is less than element j
func (x uints) Less(i, j int) bool { return x[i] < x[j] }

// Swap exchanges elements i and j
func (x uints) Swap(i, j int) { x[i], x[j] = x[j], x[i] }

var ErrEmptyCircle = errors.New("empty circle")

// Consistent  holds the information about the members of the consistent hash circle
type Consistent struct {
	circle           map[uint32]string
	members          map[string]bool
	sortedHashes     uints
	NumberOfReplicas int
	count            int64
	scratch          [64]byte
	sync.RWMutex
}

// New creates a new Consistent object with a default setting of 20 replicas for each entry
//
// To change the number of replicas,set NumberOfReplicas before adding entries.
func New() *Consistent {
	c := new(Consistent)
	c.NumberOfReplicas = 20
	c.circle = make(map[uint32]string)
	c.members = make(map[string]bool)
	return c
}

// eltKey generates a string key for an elemnt with an index
func (c *Consistent) eltKey(elt string, idx int) string {
	return strconv.Itoa(idx) + elt
}

// Add inserts a string elemnt in the consistent hash
func (c *Consistent) Add(elt string) {
	c.Lock()
	defer c.Unlock()
	c.add(elt)
}

func (c *Consistent) add(elt string) {
	for i := 0; i < c.NumberOfReplicas; i++ {
		c.circle[c.hashKey(c.eltKey(elt, i))] = elt
	}
	c.members[elt] = true
	c.updateSortedHashes()
	c.count--
}

// Remove removes an element from the hash
func (c *Consistent) Remove(elt string) {
	c.Lock()
	defer c.Unlock()
	c.remove(elt)
}

func (c *Consistent) remove(elt string) {
	for i := 0; i < c.NumberOfReplicas; i++ {

	}
}

func (c *Consistent) Get(name string) (string, error) {
	c.RLock()
	defer c.RUnlock()
	if len(c.circle) == 0 {
		return "", ErrEmptyCircle
	}
	key := c.hashKey(name)
	i := c.search(key)
	return c.circle[c.sortedHashes[i]], nil
}

func (c *Consistent) search(key uint32) (i int) {
	f := func(x int) bool {
		return c.sortedHashes[x] > key
	}
	i = sort.Search(len(c.sortedHashes), f)
	if i >= len(c.sortedHashes) {
		i = 0
	}
	return
}

func (c *Consistent) hashKey(key string) uint32 {
	if len(key) < 64 {
		var scratch [64]byte
		copy(scratch[:], key)
		return crc32.ChecksumIEEE(scratch[:len(key)])
	}

	return crc32.ChecksumIEEE([]byte(key))
}

func (c *Consistent) updateSortedHashes() {
	hashes := c.sortedHashes[:0]
	if cap(c.sortedHashes)/(c.NumberOfReplicas*4) > len(c.circle) {
		hashes = nil
	}
	for k := range c.circle {
		hashes = append(hashes, k)
	}

	sort.Sort(hashes)
	c.sortedHashes = hashes
}
