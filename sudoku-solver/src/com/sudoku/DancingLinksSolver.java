package com.sudoku;

import java.util.*;

public class DancingLinksSolver {
    private static final int SIZE = 9;
    private static final int BOX_SIZE = 3;
    private static final int CONSTRAINTS = 4;
    
    private Node header;
    private List<Node> solution;
    private List<List<Integer>> steps;
    
    static class Node {
        Node left, right, up, down;
        ColumnNode column;
        int row, col, value;
        
        Node() {
            left = right = up = down = this;
        }
    }
    
    static class ColumnNode extends Node {
        int size;
        int index;
        
        ColumnNode(int index) {
            super();
            this.size = 0;
            this.index = index;
            column = this;
        }
    }
    
    public DancingLinksSolver() {
        this.solution = new ArrayList<>();
        this.steps = new ArrayList<>();
    }
    
    private int getConstraintIndex(int constraint, int row, int col, int value) {
        switch (constraint) {
            case 0: return row * SIZE + col;
            case 1: return SIZE * SIZE + row * SIZE + (value - 1);
            case 2: return 2 * SIZE * SIZE + col * SIZE + (value - 1);
            case 3: return 3 * SIZE * SIZE + ((row / BOX_SIZE) * BOX_SIZE + col / BOX_SIZE) * SIZE + (value - 1);
        }
        return -1;
    }
    
    private ColumnNode createDLXMatrix(int[][] grid) {
        int numColumns = SIZE * SIZE * CONSTRAINTS;
        header = new ColumnNode(-1);
        ColumnNode[] columns = new ColumnNode[numColumns];
        
        for (int i = 0; i < numColumns; i++) {
            columns[i] = new ColumnNode(i);
            columns[i].left = header.left;
            columns[i].right = header;
            header.left.right = columns[i];
            header.left = columns[i];
        }
        
        for (int row = 0; row < SIZE; row++) {
            for (int col = 0; col < SIZE; col++) {
                if (grid[row][col] != 0) {
                    int value = grid[row][col];
                    addRow(row, col, value, columns);
                } else {
                    for (int value = 1; value <= SIZE; value++) {
                        addRow(row, col, value, columns);
                    }
                }
            }
        }
        
        return columns[0];
    }
    
    private void addRow(int row, int col, int value, ColumnNode[] columns) {
        Node firstNode = null;
        
        for (int constraint = 0; constraint < CONSTRAINTS; constraint++) {
            int colIndex = getConstraintIndex(constraint, row, col, value);
            Node node = new Node();
            node.column = columns[colIndex];
            node.row = row;
            node.col = col;
            node.value = value;
            
            node.up = columns[colIndex].up;
            node.down = columns[colIndex];
            columns[colIndex].up.down = node;
            columns[colIndex].up = node;
            columns[colIndex].size++;
            
            if (firstNode == null) {
                firstNode = node;
                node.left = node;
                node.right = node;
            } else {
                node.left = firstNode.left;
                node.right = firstNode;
                firstNode.left.right = node;
                firstNode.left = node;
            }
        }
    }
    
    private void cover(ColumnNode column) {
        column.right.left = column.left;
        column.left.right = column.right;
        
        for (Node row = column.down; row != column; row = row.down) {
            for (Node node = row.right; node != row; node = node.right) {
                node.down.up = node.up;
                node.up.down = node.down;
                node.column.size--;
            }
        }
    }
    
    private void uncover(ColumnNode column) {
        for (Node row = column.up; row != column; row = row.up) {
            for (Node node = row.left; node != row; node = node.left) {
                node.column.size++;
                node.down.up = node;
                node.up.down = node;
            }
        }
        column.right.left = column;
        column.left.right = column;
    }
    
    private ColumnNode chooseColumn() {
        int minSize = Integer.MAX_VALUE;
        ColumnNode chosen = null;
        
        for (ColumnNode col = (ColumnNode) header.right; col != header; col = (ColumnNode) col.right) {
            if (col.size < minSize) {
                minSize = col.size;
                chosen = col;
                if (minSize == 0) break;
            }
        }
        return chosen;
    }
    
    public boolean solve(int[][] grid) {
        solution.clear();
        steps.clear();
        createDLXMatrix(grid);
        boolean result = search(0);
        if (result) {
            reconstructGrid(grid);
        }
        return result;
    }
    
    private boolean search(int k) {
        if (header.right == header) {
            return true;
        }
        
        ColumnNode column = chooseColumn();
        if (column == null || column.size == 0) {
            return false;
        }
        
        cover(column);
        
        for (Node row = column.down; row != column; row = row.down) {
            solution.add(row);
            
            List<Integer> step = Arrays.asList(row.row, row.col, row.value);
            steps.add(step);
            
            for (Node node = row.right; node != row; node = node.right) {
                cover(node.column);
            }
            
            if (search(k + 1)) {
                return true;
            }
            
            solution.remove(solution.size() - 1);
            steps.remove(steps.size() - 1);
            
            for (Node node = row.left; node != row; node = node.left) {
                uncover(node.column);
            }
        }
        
        uncover(column);
        return false;
    }
    
    private void reconstructGrid(int[][] grid) {
        for (Node node : solution) {
            grid[node.row][node.col] = node.value;
        }
    }
    
    public List<List<Integer>> getSteps() {
        return new ArrayList<>(steps);
    }
}