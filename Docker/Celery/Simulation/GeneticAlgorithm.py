import random
import numpy as np
from . import simulation_parameters as _sp
import pickle


def get_shapes_lengths(input_dim, units, output_dim, model_name='lstm', use_bias=True):
    shapes, lengths = None, None

    if model_name == 'rnn':
        if use_bias:
            shapes = [[(input_dim, units), (units, units), (1, units)], [(units, output_dim), (1, output_dim)]]
            lengths = [input_dim * units, units * units, units, units * output_dim, output_dim]
        else:
            shapes = [[(input_dim, units), (units, units), (units, output_dim)]]
            lengths = [input_dim * units, units * units, units * output_dim]

    if model_name == 'lstm':
        if use_bias:
            shapes = [[(input_dim, units * 4), (units, units * 4), (1, units * 4)], [(units, output_dim), (1, output_dim)]]
            lengths = [input_dim * units * 4, units * units * 4, units * 4, units * output_dim, output_dim]
        else:
            shapes = [[(input_dim, units * 4), (units, units * 4), (units, output_dim)]]
            lengths = [input_dim * units * 4, units * units * 4, units * output_dim]

    return shapes, lengths


class Genotype:
    def __init__(self, length):
        self.length = length
        self.genotype = None
        self.fitness = None

    def copy(self):
        new_one = type(self)(self.length)
        new_one.genotype = self.genotype.copy()
        return new_one

    def random_init(self, init_genes, loc, scale):
        self.genotype = np.zeros(self.length, dtype=np.float32)
        numOfGenes = int(self.length * init_genes)
        genesIdx = random.sample(range(0, self.length), numOfGenes)
        genesVals = np.random.normal(loc=loc, scale=scale, size=self.length)
        for id in genesIdx:
            self.genotype[id] = genesVals[id]


class GeneticAlgorithm:
    def __init__(self, input_dim, units, output_dim, population_size, model_name='lstm', use_bias=True):
        self.population = []

        self.shapes, self.lengths = get_shapes_lengths(input_dim, units, output_dim, model_name, use_bias)

        self.population_size = population_size
        self.use_bias = use_bias

        self.model_name = model_name

    def init_population(self):
        genotype_length = sum(self.lengths)
        self.population = [Genotype(genotype_length) for i in range(self.population_size)]
        for individual in self.population:
            individual.random_init(init_genes=_sp.init_genes, loc=_sp.init_loc, scale=_sp.init_scale)

    def load_population_from_pickle(self, pickled_weights, brain_name='predator', genotype_idx=0):
        genotype_length = sum(self.lengths)
        self.population = [Genotype(genotype_length) for i in range(self.population_size)]

        genotype_template = pickle.load(pickled_weights)[brain_name][genotype_idx]
        for indv in self.population:
            indv.genotype = genotype_template.copy()

    def load_population_from_file(self, file_name, brain_name='predator', genotype_idx=0):
        genotype_length = sum(self.lengths)
        self.population = [Genotype(genotype_length) for i in range(self.population_size)]

        with open(file_name, 'rb') as f:
            genotype_template = pickle.load(f)[brain_name][genotype_idx]
            for indv in self.population:
                indv.genotype = genotype_template.copy()

    def population_shuffle(self):
        random.shuffle(self.population)

    def calc_fitness(self, fitness):
        for idx, value in enumerate(fitness):
            self.population[idx].fitness = value

        # Sort population by fitness, best to worst order
        self.population = sorted(self.population, key=lambda individual: individual.fitness, reverse=True)

    def next_generation(self):
        # Selection
        selected_individuals = GeneticAlgorithm.selection(self.population, method=_sp.selection_method, tournament_size=_sp.tournament_size)

        # Elite selection
        elite = [self.population[i].copy() for i in range(_sp.elite_size)]

        # Pairing
        parents = GeneticAlgorithm.pairing(selected_individuals, method=_sp.pairing_method)

        # Crossover
        offsprings = [GeneticAlgorithm.mating(parents[x], method=_sp.mating_method, probability=_sp.crossover_probability, lenghts=self.lengths) for x in range(len(parents))]
        offsprings = [individual for sublist in offsprings for individual in sublist]

        # Mutations
        next_gen = selected_individuals + offsprings
        for individual in next_gen:
            GeneticAlgorithm.mutation(individual, _sp.gen_mutation_chance, _sp.deletion_chance, _sp.duplication_chance, _sp.fill_chance)

        # Elite selection
        next_gen[-_sp.elite_size:] = elite

        if len(next_gen) != self.population_size:
            raise Exception("Next Gen size different than expected")

        self.population = next_gen

    @staticmethod
    def selection(population, method='Fittest Half', tournament_size=25):
        if method == 'Fittest Half':
            selected_individuals = [population[i] for i in range(len(population) // 2)]
            return selected_individuals

        elif method == 'Roulette Wheel':
            fitness = [indiv.fitness for indiv in population]
            selected_individuals = random.choices(population, weights=fitness, k=len(population)//2)
            return selected_individuals

        elif method == 'Tournament':
            selected_individuals = []
            for i in range(len(population)//2):
                selected = random.choices(population, k=tournament_size)
                selected = max(selected, key=lambda indi: indi.fitness)
                selected_individuals.append(selected)
            return selected_individuals

        else:
            raise Exception('Not such selection method found')

    @staticmethod
    def pairing(individuals, method='Fittest'):
        parents = []

        if method == 'Fittest':
            parents = [[individuals[x], individuals[x + 1]] for x in range(0, len(individuals), 2)]

        return parents

    @staticmethod
    def mating(parents, method='None', probability=1., lenghts=None):
        offsprings = [parents[0].copy(), parents[1].copy()]

        if random.random() > probability:
            return offsprings

        if method == 'None':
            pass

        elif method == 'Single Point':
            a = random.randrange(0, parents[0].length)

            offsprings[0].genotype[a:] = parents[1].genotype[a:]
            offsprings[1].genotype[a:] = parents[0].genotype[a:]

        elif method == 'Two Points':
            a = random.randrange(0, parents[0].length)
            b = random.randrange(0, parents[0].length)

            if a > b:
                a, b = b, a
            b += 1

            offsprings[0].genotype[a:b] = parents[1].genotype[a:b]
            offsprings[1].genotype[a:b] = parents[0].genotype[a:b]

        elif method == 'Single Point Per Part':
            p_s = 0
            for p_l in lenghts:
                a = random.randrange(p_s, p_s + p_l)

                offsprings[0].genotype[a:] = parents[1].genotype[a:]
                offsprings[1].genotype[a:] = parents[0].genotype[a:]

                p_s += p_l

        elif method == 'Two Points Per Part':
            p_s = 0
            for p_l in lenghts[:-1]:
                a = random.randrange(p_s, p_s + p_l)
                b = random.randrange(p_s, p_s + p_l)

                if a > b:
                    a, b = b, a
                b += 1

                offsprings[0].genotype[a:b] = parents[1].genotype[a:b]
                offsprings[1].genotype[a:b] = parents[0].genotype[a:b]

                p_s += p_l

        else:
            raise Exception('Not such mating method found')

        return offsprings

    @staticmethod
    def mutation(individual, gen_mutation_chance=0.01, deletion_chance=0.01, duplication_chance=0.01, fill_chance=0.01):
        for gen_id in range(individual.length):
            if random.random() <= gen_mutation_chance:
                individual.genotype[gen_id] = np.random.normal(loc=_sp.init_loc, scale=_sp.init_scale)

        if random.random() <= duplication_chance:
            a = random.randrange(0, individual.length)
            b = random.randrange(0, individual.length)
            if a>b:
                a,b=b,a
            p = random.randrange(0, individual.length - 1)
            individual.genotype[p:p + (b-a) + 1] = (individual.genotype[a:b + 1])[0:individual.length - p]

        if random.random() <= deletion_chance:
            a = random.randrange(0, individual.length)
            b = random.randrange(0, individual.length)
            if a>b:
                a,b=b,a
            individual.genotype[a:a+(individual.length-b-1)] = individual.genotype[b+1:]
            individual.genotype[-(b - a + 1):] = np.random.normal(loc=_sp.init_loc, scale=_sp.init_scale, size=b-a+1)

        if random.random() <= fill_chance:
            a = random.randrange(0, individual.length)
            b = random.randrange(0, individual.length)
            if a>b:
                a,b=b,a
            b+=1
            individual.genotype[a:b] = np.random.normal(0, 1, b - a)

    def to_genes(self):
        genes = []

        for individual in self.population:
            genes.append(individual.genotype)

        genes = np.array(genes).astype(np.float32)

        return genes
